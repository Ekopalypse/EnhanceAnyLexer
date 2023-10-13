module notepadpp

pub const (
	wm_user = 1024
	nppmsg = wm_user + 1000

	nppm_getcurrentscintilla = nppmsg + 4
	nppm_getcurrentlangtype = nppmsg + 5
	nppm_setcurrentlangtype = nppmsg + 6

	nppm_getnbopenfiles = nppmsg + 7
	all_open_files = 0
	primary_view = 1
	second_view = 2

	nppm_getopenfilenames = nppmsg + 8
	nppm_modelessdialog = nppmsg + 12
	modelessdialogadd = 0
	modelessdialogremove = 1

	nppm_getnbsessionfiles = nppmsg + 13
	nppm_getsessionfiles = nppmsg + 14
	nppm_savesession = nppmsg + 15
	nppm_savecurrentsession = nppmsg + 16
	nppm_getopenfilenamesprimary = nppmsg + 17
	nppm_getopenfilenamessecond = nppmsg + 18
	nppm_createscintillahandle = nppmsg + 20
	nppm_destroyscintillahandle = nppmsg + 21
	nppm_getnbuserlang = nppmsg + 22
	nppm_getcurrentdocindex = nppmsg + 23
	main_view = 0
	sub_view = 1

	nppm_setstatusbar = nppmsg + 24
	statusbar_doc_type = 0
	statusbar_doc_size = 1
	statusbar_cur_pos = 2
	statusbar_eof_format = 3
	statusbar_unicode_type = 4
	statusbar_typing_mode = 5

	nppm_getmenuhandle = nppmsg + 25
	npppluginmenu = 0
	nppmainmenu = 1
	nppm_encodesci = nppmsg + 26
	nppm_decodesci = nppmsg + 27
	nppm_activatedoc = nppmsg + 28
	nppm_launchfindinfilesdlg = nppmsg + 29
	nppm_dmmshow = nppmsg + 30
	nppm_dmmhide = nppmsg + 31
	nppm_dmmupdatedispinfo = nppmsg + 32
	nppm_dmmregasdckdlg = nppmsg + 33
	nppm_loadsession = nppmsg + 34
	nppm_dmmviewothertab = nppmsg + 35
	nppm_reloadfile = nppmsg + 36
	nppm_switchtofile = nppmsg + 37
	nppm_savecurrentfile = nppmsg + 38
	nppm_saveallfiles = nppmsg + 39
	nppm_setmenuitemcheck = nppmsg + 40
	nppm_addtoolbaricon = nppmsg + 41
	nppm_getwindowsversion = nppmsg + 42
	nppm_dmmgetpluginhwndbyname = nppmsg + 43
	nppm_makecurrentbufferdirty = nppmsg + 44
	nppm_getenablethemetexturefunc = nppmsg + 45
	nppm_getpluginsconfigdir = nppmsg + 46
	nppm_msgtoplugin = nppmsg + 47
	nppm_menucommand = nppmsg + 48
	nppm_triggertabbarcontextmenu = nppmsg + 49
	nppm_getnppversion = nppmsg + 50
	nppm_hidetabbar = nppmsg + 51
	nppm_istabbarhidden = nppmsg + 52
	nppm_getposfrombufferid = nppmsg + 57
	nppm_getfullpathfrombufferid = nppmsg + 58
	nppm_getbufferidfrompos = nppmsg + 59
	nppm_getcurrentbufferid = nppmsg + 60
	nppm_reloadbufferid = nppmsg + 61
	nppm_getbufferlangtype = nppmsg + 64
	nppm_setbufferlangtype = nppmsg + 65
	nppm_getbufferencoding = nppmsg + 66
	nppm_setbufferencoding = nppmsg + 67
	nppm_getbufferformat = nppmsg + 68
	nppm_setbufferformat = nppmsg + 69
	nppm_hidetoolbar = nppmsg + 70
	nppm_istoolbarhidden = nppmsg + 71
	nppm_hidemenu = nppmsg + 72
	nppm_ismenuhidden = nppmsg + 73
	nppm_hidestatusbar = nppmsg + 74
	nppm_isstatusbarhidden = nppmsg + 75
	nppm_getshortcutbycmdid = nppmsg + 76
	nppm_doopen = nppmsg + 77
	nppm_savecurrentfileas = nppmsg + 78
	nppm_getcurrentnativelangencoding = nppmsg + 79
	nppm_allocatesupported = nppmsg + 80
	nppm_allocatecmdid = nppmsg + 81
	nppm_allocatemarker = nppmsg + 82
	nppm_getlanguagename = nppmsg + 83
	nppm_getlanguagedesc = nppmsg + 84
	nppm_showdocswitcher = nppmsg + 85
	nppm_isdocswitchershown = nppmsg + 86
	nppm_getappdatapluginsallowed = nppmsg + 87
	nppm_getcurrentview = nppmsg + 88
	nppm_docswitcherdisablecolumn = nppmsg + 89
	nppm_geteditordefaultforegroundcolor = nppmsg + 90
	nppm_geteditordefaultbackgroundcolor = nppmsg + 91
	nppm_setsmoothfont = nppmsg + 92
	nppm_seteditorborderedge = nppmsg + 93
	nppm_savefile = nppmsg + 94
	nppm_disableautoupdate = nppmsg + 95
	nppm_removeshortcutbycmdid = nppmsg + 96
	nppm_getpluginhomepath = nppmsg + 97
	nppm_getsettingsoncloudpath = nppmsg + 98

	nppm_setlinenumberwidthmode = nppmsg + 99
	linenumwidth_dynamic = 0
	linenumwidth_constant = 1
	// bool nppm_setlinenumberwidthmode(0, int widthmode)
	// set line number margin width in dynamic width mode (linenumwidth_dynamic) or constant width mode (linenumwidth_constant)
	// it may help some plugins to disable non-dynamic line number margins width to have a smoothly visual effect while vertical scrolling the content in notepad++
	// if calling is successful return true, otherwise return false.

	nppm_getlinenumberwidthmode = nppmsg + 100
	// int nppm_getlinenumberwidthmode(0, 0)
	// get line number margin width in dynamic width mode (linenumwidth_dynamic) or constant width mode (linenumwidth_constant)

	nppm_addtoolbaricon_fordarkmode = nppmsg + 101
	// void nppm_addtoolbaricon_fordarkmode(uint funcitem[x]._cmdid, toolbariconswithdarkmode iconhandles)
	// use nppm_addtoolbaricon_fordarkmode instead obsolete nppm_addtoolbaricon which doesn't support the dark mode
	// 2 formats / 3 icons are needed:  1 * bmp + 2 * ico
	// all 3 handles below should be set so the icon will be displayed correctly if toolbar icon sets are changed by users, also in dark mode


	nppm_getexternallexerautoindentmode = nppmsg + 103
	// bool nppm_getexternallexerautoindentmode(const tchar *languagename, externallexerautoindentmode &autoindentmode)
	// get externallexerautoindentmode for an installed external programming language.
	// - standard means notepad++ will keep the same tab indentation between lines;
	// - c_like means notepad++ will perform a c-language style indentation for the selected external language;
	// - custom means a plugin will be controlling auto-indentation for the current language.
	// returned values: true for successful searches, otherwise false.

	nppm_setexternallexerautoindentmode = nppmsg + 104
	// bool nppm_setexternallexerautoindentmode(const tchar *languagename, externallexerautoindentmode autoindentmode)
	// set externallexerautoindentmode for an installed external programming language.
	// - standard means notepad++ will keep the same tab indentation between lines;
	// - c_like means notepad++ will perform a c-language style indentation for the selected external language;
	// - custom means a plugin will be controlling auto-indentation for the current language.
	// returned value: true if function call was successful, otherwise false.

	nppm_isautoindenton = nppmsg + 105
	// bool nppm_isautoindenton(0, 0)
	// returns the current use auto-indentation setting in notepad++ preferences.

	nppm_getcurrentmacrostatus = nppmsg + 106
	// macrostatus nppm_getcurrentmacrostatus(0, 0)
	// gets current enum class macrostatus { idle - means macro is not in use and it's empty, recordinprogress, recordingstopped, playingback }

	nppm_isdarkmodeenabled = nppmsg + 107
	// bool nppm_isdarkmodeenabled(0, 0)
	// returns true when notepad++ dark mode is enable, false when it is not.

	nppm_getdarkmodecolors = nppmsg + 108
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

	nppm_getcurrentcmdline = nppmsg + 109
	// int nppm_getcurrentcmdline(size_t strlen, tchar *commandlinestr)
	// get the current command line string.
	// returns the number of tchar copied/to copy.
	// users should call it with commandlinestr as null to get the required number of tchar (not including the terminating nul character),
	// allocate commandlinestr buffer with the return value + 1, then call it again to get the current command line string.

	nppm_createlexer = nppmsg + 110
	// void* nppm_createlexer(0, const tchar *lexer_name)
	// returns the ilexer pointer created by lexilla

	nppm_getbookmarkid = nppmsg + 111
	// void* nppm_getbookmarkid(0, 0)
	// returns the bookmark id

	nppm_darkmodesubclassandtheme = nppmsg + 112
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

	nppm_allocateindicator = nppmsg + 113
	// BOOL NPPM_ALLOCATEINDICATOR(int numberRequested, int* startNumber)
	// sets startNumber to the initial indicator ID if successful
	// Allocates an indicator number to a plugin: if a plugin needs to add an indicator,
	// it has to use this message to get the indicator number, in order to prevent a conflict with the other plugins.
	// Returns: TRUE if successful, FALSE otherwise

	var_not_recognized = 0
	full_current_path = 1
	current_directory = 2
	file_name = 3
	name_part = 4
	ext_part = 5
	current_word = 6
	npp_directory = 7
	current_line = 8
	current_column = 9
	npp_full_file_path = 10
	getfilenameatcursor = 11

	runcommand_user = wm_user + 3000
	nppm_getfullcurrentpath = runcommand_user + full_current_path
	nppm_getcurrentdirectory = runcommand_user + current_directory
	nppm_getfilename = runcommand_user + file_name
	nppm_getnamepart = runcommand_user + name_part
	nppm_getextpart = runcommand_user + ext_part
	nppm_getcurrentword = runcommand_user + current_word
	nppm_getnppdirectory = runcommand_user + npp_directory
	nppm_getfilenameatcursor = runcommand_user + getfilenameatcursor
	nppm_getcurrentline = runcommand_user + current_line
	nppm_getcurrentcolumn = runcommand_user + current_column
	nppm_getnppfullfilepath = runcommand_user + npp_full_file_path

	// Notification code
	nppn_first = 1000
	nppn_ready = nppn_first + 1
	nppn_tbmodification = nppn_first + 2
	nppn_filebeforeclose = nppn_first + 3
	nppn_fileopened = nppn_first + 4
	nppn_fileclosed = nppn_first + 5
	nppn_filebeforeopen = nppn_first + 6
	nppn_filebeforesave = nppn_first + 7
	nppn_filesaved = nppn_first + 8
	nppn_shutdown = nppn_first + 9
	nppn_bufferactivated = nppn_first + 10
	nppn_langchanged = nppn_first + 11
	nppn_wordstylesupdated = nppn_first + 12
	nppn_shortcutremapped = nppn_first + 13
	nppn_filebeforeload = nppn_first + 14
	nppn_fileloadfailed = nppn_first + 15
	nppn_readonlychanged = nppn_first + 16

	docstatus_readonly = 1
	docstatus_bufferdirty = 2

	nppn_docorderchanged = nppn_first + 17
	nppn_snapshotdirtyfileloaded = nppn_first + 18
	nppn_beforeshutdown = nppn_first + 19
	nppn_cancelshutdown = nppn_first + 20
	nppn_filebeforerename = nppn_first + 21
	nppn_filerenamecancel = nppn_first + 22
	nppn_filerenamed = nppn_first + 23
	nppn_filebeforedelete = nppn_first + 24
	nppn_filedeletefailed = nppn_first + 25
	nppn_filedeleted = nppn_first + 26
)
