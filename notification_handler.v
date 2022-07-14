module npp_plugin

import config

fn (mut p Plugin) check_lexer(buffer_id usize) {
	if p.debug_mode { p.logger('check_lexer: ${int(buffer_id)}') }
	lang_name := p.npp.get_language_name(buffer_id)
	if p.debug_mode { p.logger('\tnpp.get_language_name returned $lang_name') }

	p.buffer_is_of_interest = lang_name in p.lexers_to_enhance.all
	p.lexers_to_enhance.current =  p.lexers_to_enhance.all[lang_name]

	if p.debug_mode { 
		p.logger('\t${p.lexers_to_enhance.current}')
		p.logger('leaving check_lexer, buffer_is_of_interest: $p.buffer_is_of_interest') 
	}
}


fn (mut p Plugin) style(hwnd voidptr) {
	if p.debug_mode { p.logger('style') }
	start_pos, end_pos := p.editor.get_visible_area_positions(hwnd, isize(p.offset))
	if start_pos == end_pos || end_pos < start_pos { return }
	if p.debug_mode { p.logger('\t$start_pos, $end_pos') }
	p.editor.clear_visible_area(hwnd, p.indicator_id, usize(start_pos), end_pos-start_pos)
	current_lang := p.lexers_to_enhance.current
	if p.debug_mode { p.logger('\tstyle($current_lang, ${p.indicator_id})') }
	for item in current_lang.regexes {
		p.editor.scan_visible_area(
			hwnd,
			item,
			current_lang.excluded_styles,
			p.indicator_id,
			usize(start_pos),
			usize(end_pos))
	}
	if p.debug_mode { p.logger('leaving style') }
}

pub fn (mut p Plugin) on_config_file_saved() {
	if p.debug_mode { p.logger('on_config_file_saved') }
	config.read(p.config_file)
	if p.debug_mode { p.logger('leaving on_config_file_saved') }
}

pub fn (mut p Plugin) on_buffer_activated(buffer_id usize) {
	if p.debug_mode { p.logger('on_buffer_activated') }
	if p.npp.get_buffer_filename(buffer_id) == p.config_file {
		if p.debug_mode { p.logger('\tin own config file') }
		p.buffer_is_config_file = true
	} else {
		if p.debug_mode { p.logger('\tchecking if buffer is of interest') }
		p.buffer_is_config_file = false
		p.check_lexer(buffer_id)
	}
	if p.debug_mode { p.logger('leaving on_buffer_activated') }
}

pub fn (mut p Plugin) on_language_changed(buffer_id usize) {
	if p.debug_mode { p.logger('on_language_changed') }
	p.check_lexer(buffer_id)
	if p.debug_mode { p.logger('leaving on_language_changed') }
}

pub fn (mut p Plugin) on_update_ui(hwnd voidptr) {
	if p.debug_mode { p.logger('on_update_ui') }
	match true {
		// keep config file check first since buffer_is_of_interest is true anyway
		p.buffer_is_config_file { 
			if p.debug_mode { p.logger('\tstyle config file') }
			p.editor.style_config(p.active_scintilla_hwnd, p.indicator_id) 
		}
		p.buffer_is_of_interest { 
			if p.debug_mode { p.logger('\tstyle language buffer') }
			p.style(hwnd)
		}
		else{}
	}
	if p.debug_mode { p.logger('leaving on_update_ui') }
}

pub fn (mut p Plugin) on_margin_clicked(hwnd voidptr) {
	if p.debug_mode { p.logger('on_margin_clicked') }
	match true {
		// keep config file check first since buffer_is_of_interest is true anyway
		p.buffer_is_config_file { p.editor.style_config(p.active_scintilla_hwnd, p.indicator_id) }
		p.buffer_is_of_interest { p.style(hwnd) }
		else{}
	}
	if p.debug_mode { p.logger('leaving on_margin_clicked') }
}
