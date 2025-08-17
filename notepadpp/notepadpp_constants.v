module notepadpp

pub const wm_user = 1024
pub const nppmsg = wm_user + 1000

pub const nppm_getcurrentscintilla = nppmsg + 4
pub const nppm_getcurrentlangtype = nppmsg + 5
pub const nppm_setcurrentlangtype = nppmsg + 6

pub const nppm_getnbopenfiles = nppmsg + 7
pub const all_open_files = 0
pub const primary_view = 1
pub const second_view = 2

pub const nppm_getopenfilenames = nppmsg + 8
pub const nppm_modelessdialog = nppmsg + 12
pub const modelessdialogadd = 0
pub const modelessdialogremove = 1

pub const nppm_getnbsessionfiles = nppmsg + 13
pub const nppm_getsessionfiles = nppmsg + 14
pub const nppm_savesession = nppmsg + 15
pub const nppm_savecurrentsession = nppmsg + 16
pub const nppm_getopenfilenamesprimary = nppmsg + 17
pub const nppm_getopenfilenamessecond = nppmsg + 18
pub const nppm_createscintillahandle = nppmsg + 20
pub const nppm_destroyscintillahandle = nppmsg + 21
pub const nppm_getnbuserlang = nppmsg + 22
pub const nppm_getcurrentdocindex = nppmsg + 23
pub const main_view = 0
pub const sub_view = 1

pub const nppm_setstatusbar = nppmsg + 24
pub const statusbar_doc_type = 0
pub const statusbar_doc_size = 1
pub const statusbar_cur_pos = 2
pub const statusbar_eof_format = 3
pub const statusbar_unicode_type = 4
pub const statusbar_typing_mode = 5

pub const nppm_getmenuhandle = nppmsg + 25
pub const npppluginmenu = 0
pub const nppmainmenu = 1
pub const nppm_encodesci = nppmsg + 26
pub const nppm_decodesci = nppmsg + 27
pub const nppm_activatedoc = nppmsg + 28
pub const nppm_launchfindinfilesdlg = nppmsg + 29
pub const nppm_dmmshow = nppmsg + 30
pub const nppm_dmmhide = nppmsg + 31
pub const nppm_dmmupdatedispinfo = nppmsg + 32
pub const nppm_dmmregasdckdlg = nppmsg + 33
pub const nppm_loadsession = nppmsg + 34
pub const nppm_dmmviewothertab = nppmsg + 35
pub const nppm_reloadfile = nppmsg + 36
pub const nppm_switchtofile = nppmsg + 37
pub const nppm_savecurrentfile = nppmsg + 38
pub const nppm_saveallfiles = nppmsg + 39
pub const nppm_setmenuitemcheck = nppmsg + 40
pub const nppm_addtoolbaricon = nppmsg + 41
pub const nppm_getwindowsversion = nppmsg + 42
pub const nppm_dmmgetpluginhwndbyname = nppmsg + 43
pub const nppm_makecurrentbufferdirty = nppmsg + 44
pub const nppm_getenablethemetexturefunc = nppmsg + 45
pub const nppm_getpluginsconfigdir = nppmsg + 46
pub const nppm_msgtoplugin = nppmsg + 47
pub const nppm_menucommand = nppmsg + 48
pub const nppm_triggertabbarcontextmenu = nppmsg + 49
pub const nppm_getnppversion = nppmsg + 50
pub const nppm_hidetabbar = nppmsg + 51
pub const nppm_istabbarhidden = nppmsg + 52
pub const nppm_getposfrombufferid = nppmsg + 57
pub const nppm_getfullpathfrombufferid = nppmsg + 58
pub const nppm_getbufferidfrompos = nppmsg + 59
pub const nppm_getcurrentbufferid = nppmsg + 60
pub const nppm_reloadbufferid = nppmsg + 61
pub const nppm_getbufferlangtype = nppmsg + 64
pub const nppm_setbufferlangtype = nppmsg + 65
pub const nppm_getbufferencoding = nppmsg + 66
pub const nppm_setbufferencoding = nppmsg + 67
pub const nppm_getbufferformat = nppmsg + 68
pub const nppm_setbufferformat = nppmsg + 69
pub const nppm_hidetoolbar = nppmsg + 70
pub const nppm_istoolbarhidden = nppmsg + 71
pub const nppm_hidemenu = nppmsg + 72
pub const nppm_ismenuhidden = nppmsg + 73
pub const nppm_hidestatusbar = nppmsg + 74
pub const nppm_isstatusbarhidden = nppmsg + 75
pub const nppm_getshortcutbycmdid = nppmsg + 76
pub const nppm_doopen = nppmsg + 77
pub const nppm_savecurrentfileas = nppmsg + 78
pub const nppm_getcurrentnativelangencoding = nppmsg + 79
pub const nppm_allocatesupported = nppmsg + 80
pub const nppm_allocatecmdid = nppmsg + 81
pub const nppm_allocatemarker = nppmsg + 82
pub const nppm_getlanguagename = nppmsg + 83
pub const nppm_getlanguagedesc = nppmsg + 84
pub const nppm_showdocswitcher = nppmsg + 85
pub const nppm_isdocswitchershown = nppmsg + 86
pub const nppm_getappdatapluginsallowed = nppmsg + 87
pub const nppm_getcurrentview = nppmsg + 88
pub const nppm_docswitcherdisablecolumn = nppmsg + 89
pub const nppm_geteditordefaultforegroundcolor = nppmsg + 90
pub const nppm_geteditordefaultbackgroundcolor = nppmsg + 91
pub const nppm_setsmoothfont = nppmsg + 92
pub const nppm_seteditorborderedge = nppmsg + 93
pub const nppm_savefile = nppmsg + 94
pub const nppm_disableautoupdate = nppmsg + 95
pub const nppm_removeshortcutbycmdid = nppmsg + 96
pub const nppm_getpluginhomepath = nppmsg + 97
pub const nppm_getsettingsoncloudpath = nppmsg + 98

pub const nppm_setlinenumberwidthmode = nppmsg + 99
pub const linenumwidth_dynamic = 0
pub const linenumwidth_constant = 1
	// bool nppm_setlinenumberwidthmode(0, int widthmode)
	// set line number margin width in dynamic width mode (linenumwidth_dynamic) or constant width mode (linenumwidth_constant)
	// it may help some plugins to disable non-dynamic line number margins width to have a smoothly visual effect while vertical scrolling the content in notepad++
	// if calling is successful return true, otherwise return false.

pub const nppm_getlinenumberwidthmode = nppmsg + 100
	// int nppm_getlinenumberwidthmode(0, 0)
	// get line number margin width in dynamic width mode (linenumwidth_dynamic) or constant width mode (linenumwidth_constant)

pub const nppm_addtoolbaricon_fordarkmode = nppmsg + 101
	// void nppm_addtoolbaricon_fordarkmode(uint funcitem[x]._cmdid, toolbariconswithdarkmode iconhandles)
	// use nppm_addtoolbaricon_fordarkmode instead obsolete nppm_addtoolbaricon which doesn't support the dark mode
	// 2 formats / 3 icons are needed:  1 * bmp + 2 * ico
	// all 3 handles below should be set so the icon will be displayed correctly if toolbar icon sets are changed by users, also in dark mode


pub const nppm_getexternallexerautoindentmode = nppmsg + 103
	// bool nppm_getexternallexerautoindentmode(const tchar *languagename, externallexerautoindentmode &autoindentmode)
	// get externallexerautoindentmode for an installed external programming language.
	// - standard means notepad++ will keep the same tab indentation between lines;
	// - c_like means notepad++ will perform a c-language style indentation for the selected external language;
	// - custom means a plugin will be controlling auto-indentation for the current language.
	// returned values: true for successful searches, otherwise false.

pub const nppm_setexternallexerautoindentmode = nppmsg + 104
	// bool nppm_setexternallexerautoindentmode(const tchar *languagename, externallexerautoindentmode autoindentmode)
	// set externallexerautoindentmode for an installed external programming language.
	// - standard means notepad++ will keep the same tab indentation between lines;
	// - c_like means notepad++ will perform a c-language style indentation for the selected external language;
	// - custom means a plugin will be controlling auto-indentation for the current language.
	// returned value: true if function call was successful, otherwise false.

pub const nppm_isautoindenton = nppmsg + 105
	// bool nppm_isautoindenton(0, 0)
	// returns the current use auto-indentation setting in notepad++ preferences.

pub const nppm_getcurrentmacrostatus = nppmsg + 106
	// macrostatus nppm_getcurrentmacrostatus(0, 0)
	// gets current enum class macrostatus { idle - means macro is not in use and it's empty, recordinprogress, recordingstopped, playingback }

pub const nppm_isdarkmodeenabled = nppmsg + 107
	// bool nppm_isdarkmodeenabled(0, 0)
	// returns true when notepad++ dark mode is enable, false when it is not.

pub const nppm_getdarkmodecolors = nppmsg + 108
	// bool nppm_getdarkmodecolors (size_t cbsize, nppdarkmode::colors* returncolors)
	// - cbsize must be filled with sizeof(nppdarkmode::colors).
	// - returncolors must be a pre-allocated nppdarkmode::colors struct.
	// returns true when successful, false otherwise.
	// you need to uncomment the following code to use nppdarkmode::colors structure:
	//
	// namespace nppdarkmode
	// {
	//	struct colors
	//	{
	//		colorref background = 0;
	//		colorref softerbackground = 0;
	//		colorref hotbackground = 0;
	//		colorref purebackground = 0;
	//		colorref errorbackground = 0;
	//		colorref text = 0;
	//		colorref darkertext = 0;
	//		colorref disabledtext = 0;
	//		colorref linktext = 0;
	//		colorref edge = 0;
	//		colorref hotedge = 0;
	//		colorref disablededge = 0;
	//	};
	// }
	//
	// note: in the case of calling failure ("false" is returned), you may need to change nppdarkmode::colors structure to:
	// https://github.com/notepad-plus-plus/notepad-plus-plus/blob/master/powereditor/src/nppdarkmode.h#l32

pub const nppm_getcurrentcmdline = nppmsg + 109
	// int nppm_getcurrentcmdline(size_t strlen, tchar *commandlinestr)
	// get the current command line string.
	// returns the number of tchar copied/to copy.
	// users should call it with commandlinestr as null to get the required number of tchar (not including the terminating nul character),
	// allocate commandlinestr buffer with the return value + 1, then call it again to get the current command line string.

pub const nppm_createlexer = nppmsg + 110
	// void* nppm_createlexer(0, const tchar *lexer_name)
	// returns the ilexer pointer created by lexilla

pub const nppm_getbookmarkid = nppmsg + 111
	// void* nppm_getbookmarkid(0, 0)
	// returns the bookmark id

pub const nppm_darkmodesubclassandtheme = nppmsg + 112
// ULONG NPPM_DARKMODESUBCLASSANDTHEME(ULONG dmFlags, HWND hwnd)
	// Add support for generic dark mode.
	//
	// Docking panels don't need to call NPPM_DARKMODESUBCLASSANDTHEME for main hwnd.
	// Subclassing is applied automatically unless DWS_USEOWNDARKMODE flag is used.
	//
	// Might not work properly in C# plugins.
	//
	// Returns succesful combinations of flags.
	//

	// namespace NppDarkMode
	// {
		// // Standard flags for main parent after its children are initialized.
		// constexpr ULONG dmfInit =               0x0000000BUL;

		// // Standard flags for main parent usually used in NPPN_DARKMODECHANGED.
		// constexpr ULONG dmfHandleChange =       0x0000000CUL;
	// };

	// Examples:
	//
	// - after controls initializations in WM_INITDIALOG, in WM_CREATE or after CreateWindow:
	//
	//auto success = static_cast<ULONG>(::SendMessage(nppData._nppHandle, NPPM_DARKMODESUBCLASSANDTHEME, static_cast<WPARAM>(NppDarkMode::dmfInit), reinterpret_cast<LPARAM>(mainHwnd)));
	//
	// - handling dark mode change:
	//
	//extern "C" __declspec(dllexport) void beNotified(SCNotification * notifyCode)
	//{
	//	switch (notifyCode->nmhdr.code)
	//	{
	//		case NPPN_DARKMODECHANGED:
	//		{
	//			::SendMessage(nppData._nppHandle, NPPM_DARKMODESUBCLASSANDTHEME, static_cast<WPARAM>(dmfHandleChange), reinterpret_cast<LPARAM>(mainHwnd));
	//			::SetWindowPos(mainHwnd, nullptr, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED); // to redraw titlebar and window
	//			break;
	//		}
	//	}
	//}

pub const nppm_allocateindicator = nppmsg + 113
	// BOOL NPPM_ALLOCATEINDICATOR(int numberRequested, int* startNumber)
	// sets startNumber to the initial indicator ID if successful
	// Allocates an indicator number to a plugin: if a plugin needs to add an indicator,
	// it has to use this message to get the indicator number, in order to prevent a conflict with the other plugins.
	// Returns: TRUE if successful, FALSE otherwise

pub const var_not_recognized = 0
pub const full_current_path = 1
pub const current_directory = 2
pub const file_name = 3
pub const name_part = 4
pub const ext_part = 5
pub const current_word = 6
pub const npp_directory = 7
pub const current_line = 8
pub const current_column = 9
pub const npp_full_file_path = 10
pub const getfilenameatcursor = 11

pub const runcommand_user = wm_user + 3000
pub const nppm_getfullcurrentpath = runcommand_user + full_current_path
pub const nppm_getcurrentdirectory = runcommand_user + current_directory
pub const nppm_getfilename = runcommand_user + file_name
pub const nppm_getnamepart = runcommand_user + name_part
pub const nppm_getextpart = runcommand_user + ext_part
pub const nppm_getcurrentword = runcommand_user + current_word
pub const nppm_getnppdirectory = runcommand_user + npp_directory
pub const nppm_getfilenameatcursor = runcommand_user + getfilenameatcursor
pub const nppm_getcurrentline = runcommand_user + current_line
pub const nppm_getcurrentcolumn = runcommand_user + current_column
pub const nppm_getnppfullfilepath = runcommand_user + npp_full_file_path

// Notification code
pub const nppn_first = 1000
pub const nppn_ready = nppn_first + 1
pub const nppn_tbmodification = nppn_first + 2
pub const nppn_filebeforeclose = nppn_first + 3
pub const nppn_fileopened = nppn_first + 4
pub const nppn_fileclosed = nppn_first + 5
pub const nppn_filebeforeopen = nppn_first + 6
pub const nppn_filebeforesave = nppn_first + 7
pub const nppn_filesaved = nppn_first + 8
pub const nppn_shutdown = nppn_first + 9
pub const nppn_bufferactivated = nppn_first + 10
pub const nppn_langchanged = nppn_first + 11
pub const nppn_wordstylesupdated = nppn_first + 12
pub const nppn_shortcutremapped = nppn_first + 13
pub const nppn_filebeforeload = nppn_first + 14
pub const nppn_fileloadfailed = nppn_first + 15
pub const nppn_readonlychanged = nppn_first + 16

pub const docstatus_readonly = 1
pub const docstatus_bufferdirty = 2

pub const nppn_docorderchanged = nppn_first + 17
pub const nppn_snapshotdirtyfileloaded = nppn_first + 18
pub const nppn_beforeshutdown = nppn_first + 19
pub const nppn_cancelshutdown = nppn_first + 20
pub const nppn_filebeforerename = nppn_first + 21
pub const nppn_filerenamecancel = nppn_first + 22
pub const nppn_filerenamed = nppn_first + 23
pub const nppn_filebeforedelete = nppn_first + 24
pub const nppn_filedeletefailed = nppn_first + 25
pub const nppn_filedeleted = nppn_first + 26
