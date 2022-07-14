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
	main_func SCI_FN_DIRECT
	main_hwnd voidptr
	other_func SCI_FN_DIRECT
	other_hwnd voidptr
}

[inline]
fn (e Editor) call(hwnd voidptr, msg int, wparam usize, lparam isize) isize{
	if hwnd == e.main_hwnd {
		return e.main_func(hwnd, u32(msg), wparam, lparam)
	} else {
		return e.other_func(hwnd, u32(msg), wparam, lparam)
	}
}

pub fn (e Editor) get_visible_area_positions(hwnd voidptr, offset isize) (isize, isize) {
	mut first_visible_line := e.call(hwnd, sci_getfirstvisibleline, 0, 0)
	first_visible_line = e.call(hwnd, sci_doclinefromvisible, usize(first_visible_line), 0)
	lines_on_screen := e.call(hwnd, sci_linesonscreen, usize(0), 0)
	mut last_visible_line := e.call(hwnd, sci_doclinefromvisible, usize(first_visible_line+lines_on_screen), 0)

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

pub fn (e Editor) scan_visible_area(
		hwnd voidptr,
		item config.RegexSetting,
		excluded_styles []int,
		indicator_id int,
		start_pos usize,
		end_pos usize) {
	if p.debug_mode { p.logger('scan_visible_area: start_pos=$start_pos end_pos=$end_pos') }
	if item.regex.len == 0 { return }
	if p.debug_mode { p.logger('\t${item.regex}') }

	e.call(hwnd, sci_setsearchflags, usize(scfind_regexp | scfind_posix), isize(0))
	e.call(hwnd, sci_settargetstart, usize(start_pos), isize(0))
	e.call(hwnd, sci_settargetend, usize(end_pos), isize(0))

	mut found_pos := i64(e.call(hwnd, sci_searchintarget, usize(item.regex.len), isize(item.regex.str)))
	for found_pos > i64(-1) {
		if p.debug_mode { p.logger('\tfound at: ${found_pos}') }
		end:= i64(e.call(hwnd, sci_gettargetend, usize(0), isize(0)))
		current_style := int(e.call(hwnd, sci_getstyleat, usize(found_pos), isize(0)))

		if current_style !in excluded_styles {
			e.call(hwnd, sci_setindicatorcurrent, usize(indicator_id), isize(0))
			e.call(hwnd, sci_setindicatorvalue, usize(item.color | sc_indicvaluebit), isize(0))
			e.call(hwnd, sci_indicatorfillrange, usize(found_pos), isize(end-found_pos))
		}

		e.call(hwnd, sci_settargetstart, usize(end), isize(0))
		e.call(hwnd, sci_settargetend, usize(end_pos), isize(0))
		found_pos = i64(e.call(hwnd, sci_searchintarget, usize(item.regex.len), isize(item.regex.str)))
	}
}

pub fn (e Editor) init_indicator(hwnd voidptr, id usize) {
	e.call(hwnd, sci_indicsetstyle, id, isize(indic_textfore))
	e.call(hwnd, sci_indicsetflags, id, isize(sc_indicflag_valuefore))
}

pub fn (e Editor) style_config(hwnd voidptr, indicator_id int) {
	if p.debug_mode { p.logger('style_config') }
	mut first_visible_line := e.call(hwnd, sci_getfirstvisibleline, 0, 0)
	first_visible_line = e.call(hwnd, sci_doclinefromvisible, usize(first_visible_line), 0)
	lines_on_screen := e.call(hwnd, sci_linesonscreen, usize(0), 0)
	mut last_visible_line := e.call(hwnd, sci_doclinefromvisible, usize(first_visible_line+lines_on_screen), 0)

	start_pos := e.call(hwnd, sci_positionfromline, usize(first_visible_line), 0)
	end_pos := e.call(hwnd, sci_getlineendposition, usize(last_visible_line), 0)
	e.call(hwnd, sci_setsearchflags, usize(scfind_regexp | scfind_posix), isize(0))
	e.call(hwnd, sci_settargetstart, usize(start_pos), isize(0))
	e.call(hwnd, sci_settargetend, usize(end_pos), isize(0))

	mut found_pos := i64(e.call(hwnd, sci_searchintarget, usize(e.config_regex.len), isize(e.config_regex.str)))
	for found_pos > i64(-1) {
		if p.debug_mode { p.logger('\tfound at: ${found_pos}') }
		end:= i64(e.call(hwnd, sci_gettargetend, usize(0), isize(0)))
		length := end-found_pos
		// get the color text
		range_pointer := charptr(e.call(hwnd, sci_getrangepointer, usize(found_pos), isize(length)))
		color_text := unsafe { range_pointer.vstring_with_len(int(length)) }
		color := color_text.replace('#', '0x').int()
		
		e.call(hwnd, sci_setindicatorcurrent, usize(indicator_id), isize(0))
		e.call(hwnd, sci_setindicatorvalue, usize(color | sc_indicvaluebit), isize(0))
		e.call(hwnd, sci_indicatorfillrange, usize(found_pos), isize(length))

		e.call(hwnd, sci_settargetstart, usize(end), isize(0))
		e.call(hwnd, sci_settargetend, usize(end_pos), isize(0))
		found_pos = i64(e.call(hwnd, sci_searchintarget, usize(e.config_regex.len), isize(e.config_regex.str)))
	}
	if p.debug_mode { p.logger('leaving style_config') }
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
