module npp_plugin

import os
import config

fn (mut p Plugin) check_lexer() {
	view0_id, view1_id := p.npp.get_active_buffer_ids()
	lang_name0 := p.npp.get_language_name(usize(view0_id))
	lang_name1 := p.npp.get_language_name(usize(view1_id))
	p.view0_is_of_interest = lang_name0 in p.lexers_to_enhance.all
	p.view1_is_of_interest = lang_name1 in p.lexers_to_enhance.all
	p.lexers_to_enhance_view0 =  p.lexers_to_enhance.all[lang_name0]
	p.lexers_to_enhance_view1 =  p.lexers_to_enhance.all[lang_name1]
}


fn (mut p Plugin) style(hwnd voidptr, view int) {
	start_pos, end_pos := p.editor.get_visible_area_positions(hwnd, isize(p.offset))
	if start_pos == end_pos || end_pos < start_pos { return }
	p.editor.clear_visible_area(hwnd, p.indicator_id, usize(start_pos), end_pos-start_pos)
	current_lang := if view == 0 { p.lexers_to_enhance_view0 } else { p.lexers_to_enhance_view1 }
	for item in current_lang.regexes {
		p.editor.scan_visible_area(
			hwnd,
			item,
			current_lang.excluded_styles,
			p.indicator_id,
			usize(start_pos),
			usize(end_pos))
	}
}

pub fn (mut p Plugin) on_config_file_saved() {
	p.initialize()
}

pub fn (mut p Plugin) on_buffer_activated(buffer_id usize) {
	if p.npp.get_buffer_filename(buffer_id) == p.config_file {
		p.editor.init_style(p.active_scintilla_hwnd)
		p.buffer_is_config_file = true
	} else {
		p.editor.clear_regex_test(p.active_scintilla_hwnd, p.indicator_id)
		p.buffer_is_config_file = false
		p.check_lexer()
	}
}

pub fn (mut p Plugin) on_language_changed(buffer_id usize) {
	p.check_lexer()
}

fn (mut p Plugin) on_update(sci_hwnd voidptr) {
	mut hwnd := p.editor.main_hwnd
	mut buffer_is_of_interest := false
	mut view := 0
	if sci_hwnd == p.npp_data.scintilla_main_handle {
		buffer_is_of_interest = p.view0_is_of_interest
	} else {
		hwnd = p.editor.other_hwnd
		buffer_is_of_interest = p.view1_is_of_interest
		view = 1
	}
	match true {
		// keep config file check first since buffer_is_of_interest is true anyway
		p.buffer_is_config_file { p.editor.style_config(p.active_scintilla_hwnd, p.indicator_id) }
		buffer_is_of_interest { p.style(hwnd, view) }
		else{}
	}
}

pub fn (mut p Plugin) on_modified(position isize) {
	if p.buffer_is_config_file && (! p.npp.is_single_view() ) {
		p.editor.highlight_match(p.active_scintilla_hwnd, position, p.indicator_id)
	}
}

pub fn (mut p Plugin) initialize() {
	if ! os.exists(p.config_file) {
		mut f := os.create(p.config_file) or {
			err_msg := 'Unable to create ${p.config_file}\n${winapi_lasterr_str()}'
			C.MessageBoxW(p.npp_data.npp_handle, err_msg.to_wide(), 'ERROR'.to_wide(), 0)
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
; If specifying an offset, it will affect both the start and end lines.
; For example, if the currently visible lines range from 100 to 150 and an offset=10 is given,
; the regular expressions are matched with the text from lines 90 to 160.
offset=0
; The ID of the style used to display regex errors.
; If there are conflicts with other styles used by Npp or other plugins, change this value.
; The expected range is between 0 and 255; according to Scinitilla.
regex_error_style_id=30
; The color used by the style.
; For an explanation of how this color can be defined, see the following description of the regexes and their colors.
regex_error_color=0x756ce0

; Each configured lexer must have a section with its name,
; (NOTE: use the menu function "Enhance current language" as it takes care of the correct naming)
; followed by one or more lines with the syntax
; color = regular expression.
; A color is a number in the range 0 - 16777215.
; The notation is either pure digits or a hex notation starting with 0x or #,
; such as 0xff00ff or #ff00ff.
; Please note:
; * red goes in the lowest byte (0x0000FF)
; * green goes in the center byte (0x00FF00)
; * blue goes in the biggest byte (0xFF0000)
; * this BGR order might conflict with your expectation of RGB order.
; * see Microsoft COLORREF documentation https://docs.microsoft.com/en-us/windows/win32/gdi/colorref

; The optional line of excluded_styles is expected in the form of
; excluded_styles = 1,2,3,4,5 ...
; The numbers refer to the style IDs used by the lexer and
; can be taken from the file stylers.xml or USED_THEME_NAME.xml
; and in case of UDLs the mapping is only described in the source code
; https://github.com/notepad-plus-plus/notepad-plus-plus/blob/master/lexilla/include/SciLexer.h
; starting from SCE_USER_STYLE_DEFAULT

; The regular expression syntax is explained at
; https://npp-user-manual.org/docs/searching/#regular-expressions

; For example:
;
; [markdown (preinstalled)]
; ; changes the default color - useless, just to see it works.
; 0x66ad1 = \\w+
; excluded_styles = 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,20,21,22,23

; [python]
; ; function parameters
; 0x66ad1 = (?:(?:def)\\s\\w+)\\s*\\(\\K.+(?=\\):)
; ; cls and self keywords
; 2550 = \\b(cls|self)\\b
; ; args and kwargs
; 0xff33ff = (\\*|\\*\\*)\\w+
; excluded_styles = 1,3,4,6,7,12,16,17,18,19
'

		) or { return }
	} else {
		config.read(p.config_file)
	}
	p.editor.eol_error_style = p.regex_error_style_id
	p.editor.error_msg_color = p.regex_error_color
	p.editor.init_indicator(p.editor.main_hwnd, usize(p.indicator_id))
	p.editor.init_indicator(p.editor.other_hwnd, usize(p.indicator_id))

	// create and send a fake nppn_bufferactivated event to the plugin
	p.on_buffer_activated(usize(p.npp.get_current_buffer_id()))
}
