module npp_plugin

import os
import time
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
	debug_file = 'EnhanceAnyLexerDebug.log'
)

pub fn (mut p Plugin) logger(text string) {
	if p.debug_mode {
		mut f := os.open_append(p.debug_file) or {
			p.debug_mode = false
			title := 'ERROR'
			message := 'Unable to open debug log file: $p.debug_file\nDebug mode has been disabled!\n\n$text'
			C.MessageBoxW(npp_data.npp_handle, message.to_wide(), title.to_wide(), 0)
			return
		}
		f.writeln('[${time.now().format_ss_milli()}] $text') or { return }
		f.close()
	}
}

__global (
	npp_data NppData
	func_items [2]FuncItem
	editor sci.Editor
	npp notepadpp.Npp
	plugin Plugin
)

pub struct Plugin {
pub mut:
	current_scintilla_hwnd voidptr
	config_file string
	buffer_is_of_interest bool
	lexers_to_enhance config.Config
	indicator_id int
	debug_mode bool
	debug_file string
	already_styled bool
}

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
	npp_data = nppData
	e1_func := sci.SCI_FN_DIRECT(C.SendMessageW(npp_data.scintilla_main_handle, 2184, 0, 0))
	e1_hwnd := C.SendMessageW(npp_data.scintilla_main_handle, 2185, 0, 0)
	e2_func := sci.SCI_FN_DIRECT(C.SendMessageW(npp_data.scintilla_second_handle, 2184, 0, 0))
	e2_hwnd := C.SendMessageW(npp_data.scintilla_second_handle, 2185, 0, 0)

	npp = notepadpp.Npp{npp_data.npp_handle}

	editor = sci.Editor {
		main_func: e1_func
		main_hwnd: e1_hwnd
		other_func: e2_func
		other_hwnd: e2_hwnd
	}
}


[export: beNotified]
fn be_notified(notification &sci.SCNotification) {
	if !(notification.nmhdr.hwnd_from == npp_data.npp_handle ||
		 notification.nmhdr.hwnd_from == npp_data.scintilla_main_handle ||
		 notification.nmhdr.hwnd_from == npp_data.scintilla_second_handle) { return }

	match notification.nmhdr.code {
		notepadpp.nppn_ready { 
			initialize()
		}
		notepadpp.nppn_filesaved { 
			if npp.get_buffer_filename(notification.nmhdr.id_from) == plugin.config_file {
				plugin.on_config_file_saved()
			}
		}
		notepadpp.nppn_bufferactivated {
			if npp.get_current_view() == 0 {
				plugin.current_scintilla_hwnd = editor.main_hwnd
			}
			else {
				plugin.current_scintilla_hwnd = editor.other_hwnd
			}
			plugin.on_buffer_activated(notification.nmhdr.id_from)
		}
		notepadpp.nppn_langchanged {
			plugin.on_language_changed(notification.nmhdr.id_from)
		}
		sci.scn_updateui { 
			plugin.logger('scn_updateui: ${notification.nmhdr.hwnd_from} - ${npp_data.scintilla_main_handle} - ${npp_data.scintilla_second_handle}')
			if notification.nmhdr.hwnd_from == npp_data.scintilla_main_handle {
				plugin.on_update_ui(editor.main_hwnd)
			} else {
				plugin.on_update_ui(editor.other_hwnd)
			}
		}
		sci.scn_marginclick { 
			plugin.logger('scn_marginclick: ${notification.nmhdr.hwnd_from} - ${npp_data.scintilla_main_handle} - ${npp_data.scintilla_second_handle}')
			if notification.nmhdr.hwnd_from == npp_data.scintilla_main_handle {
				plugin.on_margin_clicked(editor.main_hwnd)
			} else {
				plugin.on_margin_clicked(editor.other_hwnd)
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
	unsafe { *nb_func = func_items.len }

	func_names := ['Open configuration file', 'About']
	func_ptrs := [open_config, about]

	for i in 0..func_items.len {
		mut func_name := [64]u16 {init: 0}
		for j in 0..func_names[i].len {
			func_name[j] = u16(func_names[i][j])
		}
		func_items[i].item_name = func_name
		func_items[i].p_func = func_ptrs[i]
		func_items[i].cmd_id = 0
		func_items[i].init_to_check = false
		func_items[i].p_sh_key = voidptr(0)
	}
	return &func_items[0]
}


fn initialize() {
	// plugin_config_dir := npp.get_plugin_config_dir()
	plugin_config_dir := os.join_path(npp.get_plugin_config_dir(), plugin_name)
	if ! os.exists(plugin_config_dir) {
		os.mkdir(plugin_config_dir) or { return }
	}

	plugin.debug_file = os.join_path(plugin_config_dir, debug_file)
	plugin.config_file = os.join_path(plugin_config_dir, config_file)
	// plugin.logger = logger
	if ! os.exists(plugin.config_file) {
		mut f := os.create(plugin.config_file) or { return }
		defer { f.close() }
		f.write_string('
; The configuration is stored in an ini-like syntax.
; The global section defines the indicator ID used for styling and whether logging(debug_mode) is enabled.
; A line starting with a semicolon is treated as a comment line, NO inline comment is supported.
; ONLY styling of the text foreground color is supported.
; Updates to the configuration are read when the file is saved and applied immediately 
; when the buffer of the configured lexer is reactivated.
[global]
indicator_id=0
debug_mode=0

; Each configured lexer must have a section with its name,
; followed by one or more lines with the syntax of 
; color = regular expression
; A line starting with excluded_styles is optional and, if used, follows the syntax
; excluded_styles = 1,2,3,4,5 ...
; For example:
;[python]
;1077960 = \\b(cls|self)\\b
;excluded_styles = 1,3,4,6,7,12,16,17,18,19'
		) or { return }
	} else {
		config.read(plugin.config_file)
	}
	editor.set_indicator(editor.main_hwnd, usize(plugin.indicator_id))
	editor.set_indicator(editor.other_hwnd, usize(plugin.indicator_id))
	
	// create and send a fake nppn_bufferactivated event
	plugin.on_buffer_activated(usize(npp.get_current_buffer_id()))
}


pub fn open_config() {
	if os.exists(plugin.config_file) { npp.open_document(plugin.config_file) }
}


pub fn about(){
	title := 'Enhance any lexer for Notepad++'
	text := '\tEnhanceAnyLexer v. 0.0.1 (64bit)

\tAuthor: Ekopalypse

\tCode: https://github.com/Ekopalypse/EnhanceAnyLexer
\tLicensed under GPLv2
'
	C.MessageBoxW(npp_data.npp_handle, text.to_wide(), title.to_wide(), 0)
}


[windows_stdcall]
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