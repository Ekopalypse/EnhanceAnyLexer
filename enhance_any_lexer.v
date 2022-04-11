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
	debug_mode bool
	offset int
	debug_file string
	already_styled bool
}


pub fn (mut p Plugin) logger(text string) {
	mut f := os.open_append(p.debug_file) or {
		p.debug_mode = false
		title := 'ERROR'
		message := 'Unable to open debug log file: $p.debug_file\nDebug mode has been disabled!\n\n$text'
		C.MessageBoxW(p.npp_data.npp_handle, message.to_wide(), title.to_wide(), 0)
		return
	}
	defer { f.close() }
	f.writeln('[${time.now().format_ss_milli()}] $text') or { return }
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
	e1_func := sci.SCI_FN_DIRECT(C.SendMessageW(p.npp_data.scintilla_main_handle, 2184, 0, 0))
	e1_hwnd := C.SendMessageW(p.npp_data.scintilla_main_handle, 2185, 0, 0)
	e2_func := sci.SCI_FN_DIRECT(C.SendMessageW(p.npp_data.scintilla_second_handle, 2184, 0, 0))
	e2_hwnd := C.SendMessageW(p.npp_data.scintilla_second_handle, 2185, 0, 0)

	p.npp = notepadpp.Npp{p.npp_data.npp_handle}

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
			initialize()
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
		'Open configuration file': open_config
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


fn initialize() {
	plugin_config_dir := os.join_path(p.npp.get_plugin_config_dir(), plugin_name)
	if ! os.exists(plugin_config_dir) {
		os.mkdir(plugin_config_dir) or {
			C.MessageBoxW(p.npp_data.npp_handle, 'Unable to create $plugin_config_dir'.to_wide(), 'ERROR'.to_wide(), 0)
			return
		}
	}

	p.debug_file = os.join_path(plugin_config_dir, debug_file)
	p.config_file = os.join_path(plugin_config_dir, config_file)

	if ! os.exists(p.config_file) {
		mut f := os.create(p.config_file) or {
			C.MessageBoxW(p.npp_data.npp_handle, 'Unable to create ${p.config_file}'.to_wide(), 'ERROR'.to_wide(), 0)
			return
		}
		defer { f.close() }
		f.write_string('
; The configuration is stored in an ini-like syntax.
; The global section defines the indicator ID used for styling and whether logging(debug_mode) is enabled.
; A line starting with a semicolon is treated as a comment line, NO inline comment is supported.
; ONLY styling of the text foreground color is supported.
; Updates to the configuration are read when the file is saved and applied immediately
; when the buffer of the configured lexer is reactivated.
[global]
; The ID of the indicator used to style the matches.
; If there are conflicts with indicators used by Npp or other plugins, change this value.
; The expected range is between 0 and 35; according to Scinitilla.
indicator_id=0
; A debug mode can be configured in case of styling problems. Expected values are 0 (default, disabled) and 1.
; This will create a file called EnhanceAnyLexerDebug.log in the plugins\\config\\EnhanceAnyLexer directory.
; Note that enabling logging has an impact on rendering performance - you WILL notice slowdowns.
debug_mode=0
; If specifying an offset, it will affect both the start and end lines.
; For example, if the currently visible lines range from 100 to 150 and an offset=10 is given,
; the regular expressions are matched with the text from lines 90 to 160.
offset=0

; Each configured lexer must have a section with its name
; followed by one or more lines with the syntax of
; color = regular expression
; A colour is a number in the range 0 - 16777215.
; The notation is either pure digits or a hex notation starting with 0x or #, 
; such as 0xff00ff or #ff00ff.

; The optional line of excluded_styles is expected in the form of
; excluded_styles = 1,2,3,4,5 ...
; The numbers refer to the style IDs used by the lexer and
; can be taken from the file stylers.xml or USED_THEME_NAME.xml

; For example:
;[python]
; # cls and self keywords
;1077960 = \\b(cls|self)\\b
; # function parameters
;0x669ad1 = (?:(?:def)\s\w+)\s*\(\K.+(?=\):)
; # args and kwargs
;#c2b656 = (\*|\*\*)(?=\w)
;excluded_styles = 1,3,4,6,7,12,16,17,18,19'

		) or { return }
	} else {
		config.read(p.config_file)
	}
	p.editor.init_indicator(p.editor.main_hwnd, usize(p.indicator_id))
	p.editor.init_indicator(p.editor.other_hwnd, usize(p.indicator_id))

	// create and send a fake nppn_bufferactivated event to the plugin
	p.on_buffer_activated(usize(p.npp.get_current_buffer_id()))
}


pub fn open_config() {
	if os.exists(p.config_file) { p.npp.open_document(p.config_file) }
}


pub fn about(){
	title := 'Enhance any lexer for Notepad++'
	text := '\tEnhanceAnyLexer v0.2.0

\tAuthor: Ekopalypse

\tCode: https://github.com/Ekopalypse/EnhanceAnyLexer
\tLicensed under MIT
'
	C.MessageBoxW(p.npp_data.npp_handle, text.to_wide(), title.to_wide(), 0)
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
