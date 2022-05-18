module notepadpp

fn C.SendMessageW(hwnd voidptr, msg u32, wparam usize, lparam isize) isize

pub struct Npp {
mut:
	hwnd voidptr
}

[inline]
fn (n Npp) call(msg int, wparam usize, lparam isize) isize {
	return C.SendMessageW(n.hwnd, msg, wparam, lparam)
}

[inline]
fn alloc_wide(size int) &u8 { return vcalloc((size) * 2 ) }

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
	mut buffer_size := int(n.call(nppm_getlanguagename, usize(lang_type), isize(0))) + 1
	mut buffer := alloc_wide(buffer_size)

	n.call(nppm_getlanguagename, usize(lang_type), isize(buffer))
	lang_name := unsafe { string_from_wide(buffer) }
	return lang_name.to_lower()
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
