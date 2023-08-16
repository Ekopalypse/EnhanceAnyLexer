module scintilla
import config

pub type SCI_FN_DIRECT = fn(hwnd isize, msg u32, param usize, lparam isize) isize

struct SciNotifyHeader {
pub mut:
	hwnd_from voidptr
	id_from usize
	code u32
}

pub struct SCNotification {
pub mut:
	nmhdr SciNotifyHeader
	position isize					// SCN_STYLENEEDED, SCN_DOUBLECLICK, SCN_MODIFIED, SCN_MARGINCLICK,
									// SCN_NEEDSHOWN, SCN_DWELLSTART, SCN_DWELLEND, SCN_CALLTIPCLICK,
									// SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK, SCN_HOTSPOTRELEASECLICK,
									// SCN_INDICATORCLICK, SCN_INDICATORRELEASE,
									// SCN_USERLISTSELECTION, SCN_AUTOCSELECTION

	ch int							// SCN_CHARADDED, SCN_KEY, SCN_AUTOCCOMPLETED, SCN_AUTOCSELECTION,
									// SCN_USERLISTSELECTION

	modifiers int					// SCN_KEY, SCN_DOUBLECLICK, SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK,
									// SCN_HOTSPOTRELEASECLICK, SCN_INDICATORCLICK, SCN_INDICATORRELEASE,

	modification_type int			// SCN_MODIFIED

	text &char						// SCN_MODIFIED, SCN_USERLISTSELECTION,
									// SCN_AUTOCSELECTION, SCN_URIDROPPED

	length isize					// SCN_MODIFIED
	lines_added isize				// SCN_MODIFIED
	message int						// SCN_MACRORECORD
	wparam usize					// SCN_MACRORECORD
	lparam isize					// SCN_MACRORECORD
	line isize						// SCN_MODIFIED
	fold_level_now int				// SCN_MODIFIED
	fold_level_prev int				// SCN_MODIFIED
	margin int						// SCN_MARGINCLICK
	list_type int					// SCN_USERLISTSELECTION
	x int							// SCN_DWELLSTART, SCN_DWELLEND
	y int							// SCN_DWELLSTART, SCN_DWELLEND
	token int						// SCN_MODIFIED with SC_MOD_CONTAINER
	annotation_lines_added isize	// SCN_MODIFIED with SC_MOD_CHANGEANNOTATION
	updated int						// SCN_UPDATEUI
	list_completion_method int		// SCN_AUTOCSELECTION, SCN_AUTOCCOMPLETED, SCN_USERLISTSELECTION,
	character_source int			// SCN_CHARADDED
}

pub struct Editor {
	config_regex string = r'^(?:0x|#|\d)[0-9a-fA-F]+\b'
pub:
	main_func SCI_FN_DIRECT = unsafe { nil }
	main_hwnd voidptr
	other_func SCI_FN_DIRECT  = unsafe { nil }
	other_hwnd voidptr
pub mut:
	eol_error_style int
	error_msg_color int
}

[inline]
fn (e Editor) call(hwnd voidptr, msg int, wparam usize, lparam isize) isize{
	match hwnd {
		e.main_hwnd { return e.main_func(hwnd, u32(msg), wparam, lparam) }
		e.other_hwnd { return e.other_func(hwnd, u32(msg), wparam, lparam) }
		else { return 0 }
	}
}

pub fn (e Editor) get_visible_area_positions(hwnd voidptr, offset isize) (isize, isize) {
	mut first_visible_line := e.call(hwnd, sci_getfirstvisibleline, 0, 0)
	first_line1 := e.call(hwnd, sci_doclinefromvisible, usize(first_visible_line), 0)
	first_line2 := e.call(hwnd, sci_visiblefromdocline, usize(first_visible_line), 0)

	lines_on_screen := e.call(hwnd, sci_linesonscreen, usize(0), 0)
	last_line1 := e.call(hwnd, sci_doclinefromvisible, usize(first_visible_line+lines_on_screen), 0)
	last_line2 := e.call(hwnd, sci_visiblefromdocline, usize(first_visible_line+lines_on_screen), 0)
	
	first_visible_line = if first_line1 < first_line2 { first_line1 } else { first_line2 }
	
	mut last_visible_line := if last_line1 > last_line2 { last_line1 } else { last_line2 }

	if offset > 0 {
		first_visible_line = if first_visible_line < offset { 0 } else { first_visible_line - offset }
		line_count := e.call(hwnd, sci_getlinecount, 0, 0)
		last_visible_line = if last_visible_line + offset > line_count { line_count } else { last_visible_line + offset }
	}

	start_pos := e.call(hwnd, sci_positionfromline, usize(first_visible_line), 0)
	end_pos := e.call(hwnd, sci_getlineendposition, usize(last_visible_line), 0)

	return start_pos, end_pos
}

pub fn (e Editor) clear_visible_area(hwnd voidptr, indicator_id int, start usize, length isize) {
	e.call(hwnd, sci_setindicatorcurrent, usize(indicator_id), isize(0))
	e.call(hwnd, sci_indicatorclearrange, start, length)
}

pub fn (e Editor) clear_regex_test(hwnd voidptr, indicator_id int) {
	length := e.call(hwnd, sci_getlength, 0, 0)
	e.call(hwnd, sci_setindicatorcurrent, usize(indicator_id), isize(0))
	e.call(hwnd, sci_indicatorclearrange, 0, length)
}

fn (e Editor) set_search_target(hwnd voidptr, regex string, start_pos usize, end_pos usize) isize {
	e.call(hwnd, sci_setsearchflags, usize(scfind_regexp | scfind_posix), 0)
	e.call(hwnd, sci_settargetstart, start_pos, 0)
	e.call(hwnd, sci_settargetend, end_pos, 0)
	return e.call(hwnd, sci_searchintarget, usize(regex.len), isize(regex.str))
}

fn (e Editor) style_it(hwnd voidptr, indicator_id usize, color int, found_pos usize, length isize) {
	e.call(hwnd, sci_setindicatorcurrent, indicator_id, 0)
	e.call(hwnd, sci_setindicatorvalue, usize(color | sc_indicvaluebit), 0)
	e.call(hwnd, sci_indicatorfillrange, found_pos, length)
}

pub fn (e Editor) scan_visible_area(
		hwnd voidptr,
		item config.RegexSetting,
		excluded_styles []int,
		indicator_id int,
		start_pos usize,
		end_pos usize) {
	if item.regex.len == 0 { return }
	mut found_pos := e.set_search_target(hwnd, item.regex, start_pos, end_pos)
	for (found_pos > i64(-1)) && found_pos <= end_pos {
		end:= e.call(hwnd, sci_gettargetend, usize(0), isize(0))
		current_style := int(e.call(hwnd, sci_getstyleat, usize(found_pos), 0))

		if (current_style !in excluded_styles) || (current_style in item.whitelist_styles) {
			e.style_it(hwnd, usize(indicator_id), item.color, usize(found_pos), end-found_pos)
		}

		found_pos = e.set_search_target(hwnd, item.regex, usize(end), usize(end_pos))
	}
}

pub fn (e Editor) init_indicator(hwnd voidptr, id usize) {
	e.call(hwnd, sci_indicsetstyle, id, isize(indic_textfore))
	e.call(hwnd, sci_indicsetflags, id, isize(sc_indicflag_valuefore))
	e.call(hwnd, sci_indicsetstyle, id+1, isize(indic_roundbox))
	e.call(hwnd, sci_indicsetfore, id+1, 255<<8)
	e.call(hwnd, sci_indicsetalpha, id+1, 55)
	e.call(hwnd, sci_indicsetoutlinealpha, id+1, 255)
	e.init_style(hwnd)
}

pub fn (e Editor) init_style(hwnd voidptr) {
	// eol annotation styles
	e.call(hwnd, sci_stylesetfore, usize(e.eol_error_style), e.error_msg_color)
	e.call(hwnd, sci_stylesetitalic, usize(e.eol_error_style), 1)
}

pub fn (e Editor) style_config(hwnd voidptr, indicator_id int) {
	mut first_visible_line := e.call(hwnd, sci_getfirstvisibleline, 0, 0)
	first_visible_line = e.call(hwnd, sci_doclinefromvisible, usize(first_visible_line), 0)
	lines_on_screen := e.call(hwnd, sci_linesonscreen, usize(0), 0)
	mut last_visible_line := e.call(hwnd, sci_doclinefromvisible, usize(first_visible_line+lines_on_screen), 0)

	start_pos := e.call(hwnd, sci_positionfromline, usize(first_visible_line), 0)
	end_pos := e.call(hwnd, sci_getlineendposition, usize(last_visible_line), 0)
	mut found_pos := e.set_search_target(hwnd, e.config_regex, usize(start_pos), usize(end_pos))
	for (found_pos > i64(-1)) && (found_pos <= end_pos) {
		end:= e.call(hwnd, sci_gettargetend, usize(0), isize(0))

		length := end-found_pos
		// get the color text
		range_pointer := charptr(e.call(hwnd, sci_getrangepointer, usize(found_pos), isize(length)))
		color_text := unsafe { range_pointer.vstring_with_len(int(length)) }
		color := color_text.replace('#', '0x').int()

		e.style_it(hwnd, usize(indicator_id), color, usize(found_pos), end-found_pos)
		found_pos = e.set_search_target(hwnd, e.config_regex, usize(end), usize(end_pos))
	}
}

pub fn (e Editor) append_text(hwnd voidptr, text string) {
	e.call(hwnd, sci_appendtext, usize(text.len), isize(text.str))
}

fn (e Editor) scroll_to_line(hwnd voidptr, line usize) {
	e.call(hwnd, sci_setvisiblepolicy, usize(caret_jumps | caret_even), 0)
	e.call(hwnd, sci_ensurevisibleenforcepolicy, line, 0)
	e.call(hwnd, sci_gotoline, line, 0)
}

pub fn (e Editor) goto_last_line(hwnd voidptr) {
	last_line := usize(e.call(hwnd, sci_getlinecount, 0, 0))
	e.scroll_to_line(hwnd, last_line)
}

pub fn (e Editor) goto_known_lexer(hwnd voidptr, search string) {
	end_pos := e.call(hwnd, sci_getlength, 0, 0)
	e.call(hwnd, sci_setsearchflags, 0, 0)
	e.call(hwnd, sci_settargetstart, 0, 0)
	e.call(hwnd, sci_settargetend, usize(end_pos), 0)

	mut found_pos := e.call(hwnd, sci_searchintarget, usize(search.len), isize(search.str))
	if found_pos > -1 {
		line := usize(e.call(hwnd, sci_linefromposition, usize(found_pos), 0))
		e.scroll_to_line(hwnd, line)
	}
}

pub fn (e Editor) highlight_match(hwnd voidptr, position isize, indicator_id int) {
	line := e.call(hwnd, sci_linefromposition, usize(position), 0)
	start_pos := e.call(hwnd, sci_positionfromline, usize(line), 0)

	length := e.call(hwnd, sci_getline, usize(line), 0)
	range_pointer := charptr(e.call(hwnd, sci_getrangepointer, usize(start_pos), isize(length)))
	mut text := unsafe { range_pointer.vstring_with_len(int(length)) }

	other_hwnd := match hwnd {
		e.main_hwnd { e.other_hwnd }
		else { e.main_hwnd }
	}

	e.clear_regex_test(other_hwnd, indicator_id)
	if text.len == 0 { return }

	split_pos := text.index('=') or { return }
	if split_pos > 0 {
		color_text := text[0..split_pos].trim(' ')
		color := color_text.replace('#', '0x').int()
		regex := text[split_pos..].trim_left('=').trim_space()
		if regex.len == 0 { return }

		e.call(hwnd, sci_eolannotationclearall, 0, 0)

		end_pos := e.call(other_hwnd, sci_getlength, 0, 0)
		mut found_pos := e.set_search_target(other_hwnd, regex, 0, usize(end_pos))
		if found_pos == -2 {
			e.add_error_annotation(hwnd, other_hwnd, line)
			return
		}
		for found_pos > -1 {
			end := e.call(other_hwnd, sci_gettargetend, usize(0), isize(0))
			e.style_it(other_hwnd, usize(indicator_id), color, usize(found_pos), end-found_pos)
			found_pos = e.set_search_target(other_hwnd, regex, usize(end), usize(end_pos))
		}
	}
}

pub fn (e Editor) add_error_annotation(hwnd voidptr, other_hwnd voidptr, line isize) {
	if p.npp_version >= 0x80021 {
		buffer := vcalloc(512)
		e.call(hwnd, sci_getboostregexerrmsg, 512, isize(buffer))
		e.call(hwnd, sci_eolannotationsetstyle, usize(line), e.eol_error_style)
		e.call(hwnd, sci_eolannotationsettext, usize(line), isize(buffer))
		e.call(hwnd, sci_eolannotationsetvisible, eolannotation_angle_circle, 0)
	}
}

pub fn (e Editor) clear_styled_views(indicator int) {
	for hwnd in [e.main_hwnd, e.other_hwnd] {
		length := e.call(hwnd, sci_getlength, 0, 0)
		e.clear_visible_area(hwnd, indicator, 0, length)
	}
}
