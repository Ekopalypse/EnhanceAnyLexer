module notepadpp

fn C.SendMessageW(hwnd voidptr, msg u32, wparam usize, lparam isize) isize
fn C.FindWindowExW(hWndParent voidptr, hWndChildAfter voidptr, lpszClass &u16, lpszWindow &u16) voidptr
fn C.IsWindowVisible(hWnd voidptr) bool

pub struct Npp {
mut:
	hwnd voidptr
	splitter_hwnd voidptr
}

[inline]
fn (n Npp) call(msg int, wparam usize, lparam isize) isize {
	return C.SendMessageW(n.hwnd, msg, wparam, lparam)
}

[inline]
fn alloc_wide(size int) &u8 { return vcalloc((size) * 2 ) }

pub fn (mut n Npp) init() {
	n.splitter_hwnd = C.FindWindowExW(
		n.hwnd,
		voidptr(0),
		"splitterContainer".to_wide(),
		voidptr(0)
	)
}

pub fn (n Npp) get_current_view() int {
	return int(n.call(nppm_getcurrentview, usize(0), isize(0)))
}


pub fn(n Npp) get_plugin_config_dir() string {
	buffer_size := int(n.call(nppm_getpluginsconfigdir, usize(0), isize(0))) + 1
	mut buffer := alloc_wide(buffer_size)

	n.call(nppm_getpluginsconfigdir, usize(buffer_size), isize(buffer))
	return unsafe { string_from_wide(buffer) }
}


pub fn(n Npp) open_document(filename string) {
	wide_filename := filename.to_wide()
	n.call(nppm_doopen, usize(0), isize(wide_filename))
}


pub fn(n Npp) get_language_name(buffer_id usize) string {
	lang_type := n.call(nppm_getbufferlangtype, buffer_id, isize(0))
	if lang_type == -1 {
		return 'UNKNOWN_ERROR'
	}
	mut buffer_size := int(n.call(nppm_getlanguagename, usize(lang_type), isize(0))) + 1
	mut buffer := alloc_wide(buffer_size)

	n.call(nppm_getlanguagename, usize(lang_type), isize(buffer))
	lang_name := unsafe { string_from_wide(buffer) }
	return lang_name.to_lower().replace('udf - ', '')
}


pub fn(n Npp) get_buffer_filename(buffer_id usize) string {
	buffer_size := int(n.call(nppm_getfullpathfrombufferid, buffer_id, isize(0))) + 1
	mut buffer := alloc_wide(buffer_size)

	n.call(nppm_getfullpathfrombufferid, buffer_id, isize(buffer))
	return unsafe { string_from_wide(buffer) }
}

pub fn (n Npp) get_current_buffer_id() isize {
	return n.call(nppm_getcurrentbufferid, 0, 0)
}

pub fn (n Npp) get_current_language() string {
	buffer_id := usize(n.call(nppm_getcurrentbufferid, 0, 0))
	return n.get_language_name(buffer_id)
}

pub fn (n Npp) get_current_filename() string {
	buffer_id := usize(n.call(nppm_getcurrentbufferid, 0, 0))
	return n.get_buffer_filename(buffer_id)
}

pub fn (n Npp) is_single_view() bool {
	return ! C.IsWindowVisible(n.splitter_hwnd)
}

pub fn (n Npp) move_to_other_view() {
	n.call(nppm_menucommand, 0, 10001)
}

pub fn (n Npp) get_notepad_version() usize {
	return usize(n.call(nppm_getnppversion, 0, 0))
}

pub fn (n Npp) get_active_buffer_ids() (isize, isize) {
	view0_index := n.call(nppm_getcurrentdocindex, 0, 0)
	view1_index := n.call(nppm_getcurrentdocindex, 0, 1)
	view0_id := n.call(nppm_getbufferidfrompos, usize(view0_index), 0)
	view1_id := n.call(nppm_getbufferidfrompos, usize(view1_index), 1)
	return view0_id, view1_id
}

pub fn (n Npp) check_menu(item usize, checked isize) {
	n.call(nppm_setmenuitemcheck, item, checked)
}
