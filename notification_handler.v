module npp_plugin

import config

fn (mut p Plugin) check_lexer(buffer_id usize) {
	p.logger('check_lexer: ${int(buffer_id)}')
	lang_name := p.npp.get_language_name(buffer_id).replace('udf - ', '')
	p.logger('\tnpp.get_language_name returned $lang_name')

	p.buffer_is_of_interest = false
	p.lexers_to_enhance.current = config.Lexers{}

	for l in p.lexers_to_enhance.all {
		if l.name.len > 0 && l.name == lang_name {
			p.buffer_is_of_interest = true
			p.lexers_to_enhance.current = l
			break
		}
	}
	if p.buffer_is_of_interest { p.logger('${p.lexers_to_enhance.current}') }
	p.logger('leaving check_lexer, buffer_is_of_interest: $p.buffer_is_of_interest')
}


fn (mut p Plugin) style(hwnd voidptr) {
	p.logger('style')
	start_pos, end_pos := p.editor.get_visible_area_positions(hwnd, isize(p.offset))
	if start_pos == end_pos || end_pos < start_pos { return }
	p.logger('\t $start_pos, $end_pos')
	p.editor.clear_visible_area(hwnd, p.indicator_id, usize(start_pos), end_pos-start_pos)
	current_lang := p.lexers_to_enhance.current
	p.logger('\tstyle($current_lang, ${p.indicator_id})')
	for item in current_lang.regexes {
		p.editor.scan_visible_area(
			hwnd,
			item,
			current_lang.excluded_styles,
			p.indicator_id,
			usize(start_pos),
			usize(end_pos))
	}
	p.logger('leaving style')
}

pub fn (mut p Plugin) on_config_file_saved() {
	p.logger('on_config_file_saved')
	config.read(p.config_file)
	p.logger('leaving on_config_file_saved')
}

pub fn (mut p Plugin) on_buffer_activated(buffer_id usize) {
	p.logger('on_buffer_activated')
	p.check_lexer(buffer_id)
	p.logger('leaving on_buffer_activated')
}

pub fn (mut p Plugin) on_language_changed(buffer_id usize) {
	p.logger('on_language_changed')
	p.check_lexer(buffer_id)
	p.logger('leaving on_language_changed')
}

pub fn (mut p Plugin) on_update_ui(hwnd voidptr) {
	p.logger('on_update_ui')
	if p.buffer_is_of_interest {
		p.style(hwnd)
	}
	p.logger('leaving on_update_ui')
}

pub fn (mut p Plugin) on_margin_clicked(hwnd voidptr) {
	p.logger('on_margin_clicked')
	if p.buffer_is_of_interest {
		p.style(hwnd)
	}
	p.logger('leaving on_margin_clicked')
}
