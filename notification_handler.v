module npp_plugin

import os
import config

fn (mut plug Plugin) check_lexer() {
	view0_id, view1_id := plug.npp.get_active_buffer_ids()
	plug.same_document_in_both_views = view0_id == view1_id
	lang_name0 := plug.npp.get_language_name(usize(view0_id))
	lang_name1 := plug.npp.get_language_name(usize(view1_id))
	plug.view0_is_of_interest = lang_name0 in plug.lexers_to_enhance.all
	plug.view1_is_of_interest = lang_name1 in plug.lexers_to_enhance.all
	plug.lexers_to_enhance_view0 =  plug.lexers_to_enhance.all[lang_name0]
	plug.lexers_to_enhance_view1 =  plug.lexers_to_enhance.all[lang_name1]
}


fn (mut plug Plugin) style(hwnd voidptr, view int) {
	start_pos, end_pos := plug.editor.get_visible_area_positions(hwnd, isize(plug.offset))
	if start_pos == end_pos || end_pos < start_pos { return }
	plug.editor.clear_visible_area(hwnd, plug.indicator_id, usize(start_pos), end_pos-start_pos)
	current_lang := if view == 0 { plug.lexers_to_enhance_view0 } else { plug.lexers_to_enhance_view1 }
	for item in current_lang.regexes {
		plug.editor.scan_visible_area(
			hwnd,
			item,
			current_lang.excluded_styles,
			plug.indicator_id,
			usize(start_pos),
			usize(end_pos))
	}
}

pub fn (mut plug Plugin) on_config_file_saved() {
	plug.initialize()
}

pub fn (mut plug Plugin) on_buffer_activated(buffer_id usize) {
	if plug.npp.get_buffer_filename(buffer_id) == plug.config_file {
		plug.editor.init_style(plug.active_scintilla_hwnd)
		plug.buffer_is_config_file = true
	} else {
		plug.editor.clear_regex_test(plug.active_scintilla_hwnd, plug.indicator_id)
		plug.buffer_is_config_file = false
		plug.check_lexer()
	}
}

pub fn (mut plug Plugin) on_language_changed(buffer_id usize) {
	plug.check_lexer()
}

fn (mut plug Plugin) on_update(sci_hwnd voidptr, update_reason isize) {
	mut hwnd := plug.editor.main_hwnd
	mut buffer_is_of_interest := false
	mut view := 0
	if sci_hwnd == plug.npp_data.scintilla_main_handle {
		buffer_is_of_interest = plug.view0_is_of_interest
	} else {
		view = 1
		hwnd = plug.editor.other_hwnd
		buffer_is_of_interest = plug.view1_is_of_interest
	}

	if (plug.npp.get_current_view() != view)	// this is a notification for the incative view
		&& plug.same_document_in_both_views		// which is a clone from the active view
		&& ((update_reason & 0x1) != 0) {		// and either the contents, styling or markers may have been changed
		return									// then we return - which means, scrolling the inactive view should still work.
	}

	match true {
		// keep config file check first since buffer_is_of_interest is true anyway
		plug.buffer_is_config_file { plug.editor.style_config(plug.active_scintilla_hwnd, plug.indicator_id, plug.lexers_to_enhance.use_rgb_format) }
		buffer_is_of_interest { plug.style(hwnd, view) }
		else{}
	}
}

pub fn (mut plug Plugin) on_modified(position isize) {
	if plug.buffer_is_config_file && (! plug.npp.is_single_view() ) {
		plug.editor.highlight_match(plug.active_scintilla_hwnd, position, plug.indicator_id, plug.lexers_to_enhance.use_rgb_format)
	}
}

pub fn (mut plug Plugin) initialize() {
	if ! os.exists(plug.config_file) {
		mut f := os.create(plug.config_file) or {
			err_msg := 'Unable to create ${plug.config_file}\n${winapi_lasterr_str()}'
			C.MessageBoxW(plug.npp_data.npp_handle, err_msg.to_wide(), 'ERROR'.to_wide(), 0)
			return
		}
		defer { f.close() }
		f.write_string('
; The configuration is stored in an ini-like syntax.
; The global section defines the indicator ID used for styling.
; A line starting with a semicolon is treated as a comment line, NO inline comment is supported.
; ONLY styling of the text foreground color is supported.
; Updates to the configuration are read when the file is saved and applied immediately
; when the buffer of the configured lexer is reactivated.
[global]
; The ID of the indicator used to style the matches.
; The plugin will try to request an ID from Npp, but if this fails, it will fall back to the ID configured here.
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
; Using the RGB format instead of the default BGR format.
; The expected values are 0 (BGR) or 1 (RGB)
use_rgb_format=0

; Each configured lexer must have a section with its name,
; (NOTE: use the menu function "Enhance current language" as it takes care of the correct naming)
; followed by one or more lines with the syntax
; color[optional whitelist] = regular expression.
; A color is a number in the range 0 - 16777215.
; The notation is either pure digits or a hex notation starting with 0x or #,
; such as 0xff00ff or #ff00ff.
; Please note:
; * red goes in the lowest byte (0x0000FF)
; * green goes in the center byte (0x00FF00)
; * blue goes in the biggest byte (0xFF0000)
; * this BGR order might conflict with your expectation of RGB order.
; * see Microsoft COLORREF documentation https://docs.microsoft.com/en-us/windows/win32/gdi/colorref
; If the RGB format is to be used, set the global variable use_rgb_format=1

; The optional whitelist is expected in the form of [1,3,16 ... ] which correspond to the style IDs of the current lexer.
; A whitelist is only useful if an excluded_styles line has been configured
; and means that this regex will ignore the excluded_styles list for these IDs and apply its style.
; See excluded_styles for further information.

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
		config.read(plug.config_file)
	}
	plug.editor.eol_error_style = plug.regex_error_style_id
	plug.editor.error_msg_color = plug.regex_error_color
	plug.editor.init_indicator(plug.editor.main_hwnd, usize(plug.indicator_id))
	plug.editor.init_indicator(plug.editor.other_hwnd, usize(plug.indicator_id))

	// create and send a fake nppn_bufferactivated event to the plugin
	plug.on_buffer_activated(usize(plug.npp.get_current_buffer_id()))
}
