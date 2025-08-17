module npp_plugin

import os
import notepadpp
import scintilla as sci
import config

#include "version.h"

fn C._vinit(int, voidptr)
fn C._vcleanup()
fn C.GC_INIT()
fn C.MessageBoxW(voidptr, &u16, &u16, u32)

const plugin_name = unsafe { cstring_to_vstring(voidptr(C.VER_PRODUCTNAME_STR)) }
const config_file = '${plugin_name}Config.ini'
const disable_plugin_flag_file = "${plugin_name}_disabled"
const config_file_saved = 1


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
	p_func fn() = unsafe { nil }
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
	view0_is_of_interest bool
	view1_is_of_interest bool
	buffer_is_config_file bool
	lexers_to_enhance config.Config
	lexers_to_enhance_view0 config.Lexer
	lexers_to_enhance_view1 config.Lexer
	indicator_id int = -1
	offset int
	npp_version usize
	regex_error_style_id int = 30
	regex_error_color int = 0x756ce0
	plugin_config_dir string
	plugin_enabled bool = true
	same_document_in_both_views bool
}


@[export: isUnicode]
fn is_unicode() bool {
	return true
}


@[export: getName]
fn get_name() &u16 {
	return plugin_name.to_wide()
}

@[export: setInfo]
fn set_info(nppData NppData) {
	p.npp_data = nppData
	e1_func := sci.SCI_FN_DIRECT(voidptr(C.SendMessageW(p.npp_data.scintilla_main_handle, sci.sci_getdirectfunction, 0, 0)))
	e1_hwnd := C.SendMessageW(p.npp_data.scintilla_main_handle, sci.sci_getdirectpointer, 0, 0)
	e2_func := sci.SCI_FN_DIRECT(voidptr(C.SendMessageW(p.npp_data.scintilla_second_handle, sci.sci_getdirectfunction, 0, 0)))
	e2_hwnd := C.SendMessageW(p.npp_data.scintilla_second_handle, sci.sci_getdirectpointer, 0, 0)

	p.npp = notepadpp.Npp{hwnd: p.npp_data.npp_handle}
	p.npp.init()

	p.editor = sci.Editor {
		main_func: e1_func
		main_hwnd: voidptr(e1_hwnd)
		other_func: e2_func
		other_hwnd: voidptr(e2_hwnd)
	}
}


@[export: beNotified]
fn be_notified(notification &sci.SCNotification) {
	if !(notification.nmhdr.hwnd_from == p.npp_data.npp_handle ||
		 notification.nmhdr.hwnd_from == p.npp_data.scintilla_main_handle ||
		 notification.nmhdr.hwnd_from == p.npp_data.scintilla_second_handle) { return }

	match notification.nmhdr.code {
		notepadpp.nppn_ready {
			p.npp_version = p.npp.get_notepad_version()
			p.plugin_config_dir = os.join_path(p.npp.get_plugin_config_dir(), plugin_name)
			if ! os.exists(p.plugin_config_dir) {
				os.mkdir(p.plugin_config_dir) or {
					err_msg := 'Unable to create ${p.plugin_config_dir}\n${winapi_lasterr_str()}'
					C.MessageBoxW(p.npp_data.npp_handle, err_msg.to_wide(), 'ERROR'.to_wide(), 0)
					return
				}
			}
			if os.exists(os.join_path(p.plugin_config_dir, disable_plugin_flag_file)) {
				p.plugin_enabled = false
				set_menu_plugin_disabled(1)
			} else {
				set_menu_plugin_disabled(0)
			}
			p.config_file = os.join_path(p.plugin_config_dir, config_file)
			if p.npp_version >= 0x80230 {
				if ! p.npp.request_inidicator_ids(1, mut &p.indicator_id) {
					p.indicator_id = -1
				}
			}
			p.initialize()
		}
		notepadpp.nppn_filesaved {
			if p.npp.get_buffer_filename(notification.nmhdr.id_from) == p.config_file {
				p.on_config_file_saved()
			}
		}
		notepadpp.nppn_bufferactivated {
			if ! p.plugin_enabled { return }
			if p.npp.get_current_view() == 0 {
				p.active_scintilla_hwnd = p.editor.main_hwnd
			} else {
				p.active_scintilla_hwnd = p.editor.other_hwnd
			}
			p.on_buffer_activated(notification.nmhdr.id_from)
		}
		notepadpp.nppn_langchanged {
			if ! p.plugin_enabled { return }
			p.on_language_changed(notification.nmhdr.id_from)
		}
		notepadpp.nppn_shutdown {
			disable_flag_file := os.join_path(p.plugin_config_dir, disable_plugin_flag_file)
			if ! p.plugin_enabled {
				os.create(disable_flag_file) or { return }
			} else {
				os.rm(disable_flag_file) or { return }
			}
		}
		sci.scn_updateui {
			if ! p.plugin_enabled { return }
			p.on_update(notification.nmhdr.hwnd_from, notification.updated)
		}
		sci.scn_modified {
			if ! p.plugin_enabled { return }
			mod_type := notification.modification_type & (sci.sc_mod_inserttext | sci.sc_mod_deletetext)
			if mod_type > 0 {
				p.on_modified(notification.position)
			}
		}
		sci.scn_marginclick {
			if ! p.plugin_enabled { return }
			p.on_update(notification.nmhdr.hwnd_from, -1)
		}
		else {}
	}
}


@[export: messageProc]
fn message_proc(msg u32, wparam usize, lparam isize) isize {
	if msg == notepadpp.nppm_msgtoplugin {
		ci := unsafe { &notepadpp.CommunicationInfo(voidptr(lparam)) }
		if ci.internal_msg == config_file_saved {
			p.on_config_file_saved()
		}
		return 0
	}
	return 1
}


@[export: getFuncsArray]
fn get_funcs_array(mut nb_func &int) &FuncItem {
	menu_functions := {
		'Enhance current language': create_for_current_language
		'Disable plugin': toggle_on_off
		'---': voidptr(0)
		'About': about
	}
	mut i := 0
	for k, v in menu_functions {
		mut func_name := [64]u16 {init: 0}
		func_name_length := k.len*2
		unsafe { C.memcpy(&func_name[0], k.to_wide(), if func_name_length < 64 { func_name_length } else { 63 }) }
		p.func_items << FuncItem {
			item_name: func_name
			p_func: v
			cmd_id: i
			init_to_check: false
			p_sh_key: voidptr(0)
		}
		i += 1
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
; Each 3-digit number is styled with the color 0xff0050.
; Matches styled by IDs 3 and 6 are recolored.
0xff0050[3, 6] = \\d{3}
; Each word "test" is styled with the color 0x00bb00
; but only if the matches are not already styled by one of the IDs in excluded_styles.
0x00bb00 = test
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
		p.npp.move_to_other_view()
	}
}

fn set_menu_plugin_disabled(checked isize) {
	p.npp.check_menu(usize(p.func_items[1].cmd_id), checked)
}

pub fn toggle_on_off() {
	p.plugin_enabled = !p.plugin_enabled
	checked := if p.plugin_enabled {
		0
	} else {
		p.editor.clear_styled_views(p.indicator_id)
		1
	}
	set_menu_plugin_disabled(checked)
}

pub fn about(){
	version := unsafe { cstring_to_vstring(voidptr(C.VER_VERSION_STR)) }
	title := unsafe { cstring_to_vstring(voidptr(C.VER_FILEDESCRIPTION_STR)) }
	product := unsafe { cstring_to_vstring(voidptr(C.VER_PRODUCTNAME_STR)) }
	text := '\t${product} v${version}

\tAuthor: Ekopalypse

\tCode: https://github.com/Ekopalypse/EnhanceAnyLexer
\tLicensed under MIT
'
	C.MessageBoxW(p.npp_data.npp_handle, text.to_wide(), title.to_wide(), 0)
}
