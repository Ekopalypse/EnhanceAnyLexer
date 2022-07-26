module npp_plugin

import os
import notepadpp
import scintilla as sci
import config

fn C._vinit(int, voidptr)
fn C._vcleanup()
fn C.GC_INIT()
fn C.MessageBoxW(voidptr, &u16, &u16, u32)

const (
	plugin_name = 'EnhanceAnyLexer'
	config_file = 'EnhanceAnyLexerConfig.ini'
)

__global ( p Plugin )

struct NppData {
mut:
	npp_handle voidptr
	scintilla_main_handle voidptr
	scintilla_second_handle voidptr
}

struct FuncItem {
mut:
	item_name [64]u16
	p_func fn()
	cmd_id int
	init_to_check bool
	p_sh_key voidptr
}

pub struct Plugin {
pub mut:
	editor sci.Editor
	npp_data NppData
	npp notepadpp.Npp
	func_items []FuncItem
	active_scintilla_hwnd voidptr
	config_file string
	buffer_is_of_interest bool
	buffer_is_config_file bool
	lexers_to_enhance config.Config
	indicator_id int
	offset int
	already_styled bool
	npp_version usize
	regex_error_style_id int = 30
	regex_error_color int = 0x756ce0
}


[export: isUnicode]
fn is_unicode() bool {
	return true
}


[export: getName]
fn get_name() &u16 {
	return plugin_name.to_wide()
}


[export: setInfo]
fn set_info(nppData NppData) {
	p.npp_data = nppData
	e1_func := sci.SCI_FN_DIRECT(C.SendMessageW(p.npp_data.scintilla_main_handle, sci.sci_getdirectfunction, 0, 0))
	e1_hwnd := C.SendMessageW(p.npp_data.scintilla_main_handle, sci.sci_getdirectpointer, 0, 0)
	e2_func := sci.SCI_FN_DIRECT(C.SendMessageW(p.npp_data.scintilla_second_handle, sci.sci_getdirectfunction, 0, 0))
	e2_hwnd := C.SendMessageW(p.npp_data.scintilla_second_handle, sci.sci_getdirectpointer, 0, 0)

	p.npp = notepadpp.Npp{hwnd: p.npp_data.npp_handle}
	p.npp.init()

	p.editor = sci.Editor {
		main_func: e1_func
		main_hwnd: e1_hwnd
		other_func: e2_func
		other_hwnd: e2_hwnd
	}
}


[export: beNotified]
fn be_notified(notification &sci.SCNotification) {
	if !(notification.nmhdr.hwnd_from == p.npp_data.npp_handle ||
		 notification.nmhdr.hwnd_from == p.npp_data.scintilla_main_handle ||
		 notification.nmhdr.hwnd_from == p.npp_data.scintilla_second_handle) { return }

	match notification.nmhdr.code {
		notepadpp.nppn_ready {
			p.npp_version = p.npp.get_notepad_version()
			plugin_config_dir := os.join_path(p.npp.get_plugin_config_dir(), plugin_name)
			if ! os.exists(plugin_config_dir) {
				os.mkdir(plugin_config_dir) or {
					err_msg := 'Unable to create ${plugin_config_dir}\n${winapi_lasterr_str()}'
					C.MessageBoxW(p.npp_data.npp_handle, err_msg.to_wide(), 'ERROR'.to_wide(), 0)
					return
				}
			}
			p.config_file = os.join_path(plugin_config_dir, config_file)
			p.initialize()
		}
		notepadpp.nppn_filesaved {
			if p.npp.get_buffer_filename(notification.nmhdr.id_from) == p.config_file {
				p.on_config_file_saved()
			}
		}
		notepadpp.nppn_bufferactivated {
			if p.npp.get_current_view() == 0 {		
				p.active_scintilla_hwnd = p.editor.main_hwnd
			} else {
				p.active_scintilla_hwnd = p.editor.other_hwnd
			}
			p.on_buffer_activated(notification.nmhdr.id_from)
		}
		notepadpp.nppn_langchanged {
			p.on_language_changed(notification.nmhdr.id_from)
		}
		sci.scn_updateui {
			if notification.nmhdr.hwnd_from == p.npp_data.scintilla_main_handle {
				p.on_update_ui(p.editor.main_hwnd)
			} else {
				p.on_update_ui(p.editor.other_hwnd)
			}
		}
		sci.scn_modified {
			mod_type := notification.modification_type & (sci.sc_mod_inserttext | sci.sc_mod_deletetext)
			if mod_type > 0 {
				p.on_modified(notification.position)
			}
		}
		sci.scn_marginclick {
			if notification.nmhdr.hwnd_from == p.npp_data.scintilla_main_handle {
				p.on_margin_clicked(p.editor.main_hwnd)
			} else {
				p.on_margin_clicked(p.editor.other_hwnd)
			}
		}
		else {}
	}
}


[export: messageProc]
fn message_proc(msg u32, wparam usize, lparam isize) isize {
	return isize(1)
}


[export: getFuncsArray]
fn get_funcs_array(mut nb_func &int) &FuncItem {
	menu_functions := {
		'Enhance current language': create_for_current_language
		'About': about
	}
	for k, v in menu_functions {
		mut func_name := [64]u16 {init: 0}
		func_name_length := k.len*2
		unsafe { C.memcpy(&func_name[0], k.to_wide(), if func_name_length < 64 { func_name_length } else { 63 }) }
		p.func_items << FuncItem {
			item_name: func_name
			p_func: v
			cmd_id: 0
			init_to_check: false
			p_sh_key: voidptr(0)
		}
	}

	unsafe { *nb_func = p.func_items.len }
	return p.func_items.data
}

pub fn create_for_current_language() {
	current_language := p.npp.get_current_language()
	if ! os.exists(p.config_file) {
		err_msg := 'Cannot find ${p.config_file}'
		C.MessageBoxW(p.npp_data.npp_handle, err_msg.to_wide(), 'ERROR'.to_wide(), 0)
		return
	}
	mut lexer_already_defined := current_language in p.lexers_to_enhance.all

	open_config()
	if ! (p.npp.get_current_filename() == p.config_file) {
		err_msg := 'Unable to open ${p.config_file}'
		C.MessageBoxW(p.npp_data.npp_handle, err_msg.to_wide(), 'ERROR'.to_wide(), 0)
		return
	}
	if ! lexer_already_defined {
		tmpl := '
[${current_language}]
; color each word
0x66ad1 = \\w+
; check in the respective styler xml if the following IDs are valid
excluded_styles = 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,20,21,22,23
'
		p.editor.append_text(p.active_scintilla_hwnd, tmpl)
		p.editor.goto_last_line(p.active_scintilla_hwnd)
	} else {
		p.editor.goto_known_lexer(p.active_scintilla_hwnd, '[${current_language}]')
	}
}

pub fn open_config() {
	if os.exists(p.config_file) { 
		p.npp.open_document(p.config_file) 
		if p.npp.is_single_view() {
			p.npp.move_to_other_view()
		}
	}
}


pub fn about(){
	title := 'Enhance any lexer for Notepad++'
	text := '\tEnhanceAnyLexer v0.4.0

\tAuthor: Ekopalypse

\tCode: https://github.com/Ekopalypse/EnhanceAnyLexer
\tLicensed under MIT
'
	C.MessageBoxW(p.npp_data.npp_handle, text.to_wide(), title.to_wide(), 0)
}


[callconv: stdcall]
[export: DllMain]
fn current(hinst voidptr, fdw_reason int, lp_reserved voidptr) bool{
	match fdw_reason {
		C.DLL_PROCESS_ATTACH {
			$if static_boehm ? {
				C.GC_INIT()
			}
			C._vinit(0, 0)
		}
		C.DLL_THREAD_ATTACH {
		}
		C.DLL_THREAD_DETACH {}
		C.DLL_PROCESS_DETACH {}
		else { return false }
	}
	return true
}
