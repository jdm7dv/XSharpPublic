VOSTRUCT _winPOINTF
	MEMBER x AS REAL4
	MEMBER y AS REAL4
VOSTRUCT _winCONTROLINFO
	MEMBER cb AS DWORD
	MEMBER hAccel AS PTR
	MEMBER cAccel AS WORD
	MEMBER dwFlags AS DWORD
	
VOSTRUCT _winCONNECTDATA
	MEMBER pUnk AS PTR
	MEMBER dwCookie AS DWORD
	
	
VOSTRUCT _winLICINFO
	MEMBER cbLicInfo AS LONGINT
	MEMBER fRuntimeKeyAvail AS LOGIC
	MEMBER fLicVerified AS LOGIC

VOSTRUCT _WINCAUUID
	MEMBER cElems AS DWORD
	MEMBER pElems AS _winGUID

VOSTRUCT tagCALPOLESTR
	MEMBER cElems AS DWORD
	MEMBER pElems  AS PSZ
	
	
	
	
	
VOSTRUCT _winCADWORD
	MEMBER  cElems AS DWORD
	MEMBER  pElems AS DWORD PTR
	
	
	
	
VOSTRUCT _winOCPFIPARAMS
	MEMBER cbStructSize AS DWORD
	MEMBER hWndOwner AS PTR
	MEMBER x AS INT
	MEMBER y AS INT
	MEMBER lpszCaption AS PSZ
	MEMBER cObjects AS DWORD
	MEMBER  lplpUnk AS PTR
	MEMBER cPages AS DWORD
	MEMBER lpPages AS _winGUID
	MEMBER lcid AS DWORD
	MEMBER dispidInitialProperty AS LONGINT
	
	
	
	
VOSTRUCT winPROPPAGEINFO
	MEMBER  cb AS DWORD
	MEMBER  pszTitle AS PSZ
	MEMBER  size IS _winSize
	MEMBER  pszDocString AS PSZ
	MEMBER  pszHelpFile AS PSZ
	MEMBER  dwHelpContext AS DWORD
	
	
VOSTRUCT _winFONTDESC
	MEMBER cbSizeofstruct AS DWORD
	MEMBER lpstrName AS PSZ
	MEMBER cySize IS _wincy
	MEMBER sWeight AS SHORTINT
	MEMBER sCharset AS SHORTINT
	MEMBER fItalic AS LOGIC
	MEMBER fUnderline AS LOGIC
	MEMBER fStrikethrough AS LOGIC
	
	
VOSTRUCT bmp_win
	
	MEMBER hbitmap AS PTR
	MEMBER  hpal AS PTR
	
	
VOSTRUCT wmf_win
	MEMBER hmeta AS PTR
	MEMBER xExt AS INT
	MEMBER yExt AS INT
	
VOSTRUCT icon_win
	MEMBER  hicon AS PTR
	
VOSTRUCT _winPICTDESC
	MEMBER cbSizeofstruct AS DWORD
	MEMBER picType AS DWORD
	MEMBER  uPICTDESC IS uPICTDESC_win
	
	
_DLL FUNC OleCreatePropertyFrame(hwndOwner AS PTR, x AS DWORD, y AS DWORD,;
		lpszCaption AS PSZ, cObjects AS DWORD, ppUnk  AS PTR,;
		cPages AS DWORD, pPageClsId AS _winGUID, lcid AS DWORD,;
		dwReserved AS DWORD, prReserved AS PTR) AS LONG PASCAL:MFCANS32.OleCreatePropertyFrame
	
	
_DLL FUNC OleCreatePropertyFrameIndirect(lpParams AS _winOCPFIPARAMS);
		AS LONG PASCAL:MFCANS32.OleCreatePropertyFrameIndirect
	
	
	
_DLL FUNC OleTranslateColor(clr AS DWORD,  hpal AS PTR, lpcolorref AS DWORD);
		AS LONG PASCAL:OLEPRO32.OleTranslateColor
	
	
_DLL FUNC OleCreateFontIndirect( lpFontdesc AS _winFontDesc, riid AS _winGUID,;
		lplpvpbj AS PTR) AS LONG PASCAL:MFCANS32.OleCreateFontIndirect
	
UNION uPICTDESC_win
	MEMBER bmp IS bmp_win
	MEMBER wmf IS wmf_win
	MEMBER icon IS icon_win



#region defines
DEFINE triUnchecked := 0
DEFINE triChecked := 1
DEFINE triGray := 2
DEFINE VT_STREAMED_PROPSET  := 73
DEFINE VT_STORED_PROPSET    :=74
DEFINE VT_BLOB_PROPSET      :=75
DEFINE VT_VERBOSE_ENUM	    :=76
DEFINE VT_COLOR            := 3
DEFINE VT_XPOS_PIXELS      := 3
DEFINE VT_YPOS_PIXELS      := 3
DEFINE VT_XSIZE_PIXELS     := 3
DEFINE VT_YSIZE_PIXELS     := 3
DEFINE VT_XPOS_HIMETRIC    := 3
DEFINE VT_YPOS_HIMETRIC    := 3
DEFINE VT_XSIZE_HIMETRIC   := 3
DEFINE VT_YSIZE_HIMETRIC   := 3
DEFINE VT_TRISTATE         := 2
DEFINE VT_OPTEXCLUSIVE     := 11
DEFINE VT_FONT             := 9
DEFINE VT_PICTURE          := 9
DEFINE VT_HANDLE           := 3
DEFINE OCM__BASE              := (WM_USER+0x1c00)
DEFINE OCM_COMMAND            := (OCM__BASE + WM_COMMAND)
DEFINE OCM_CTLCOLORBTN        := (OCM__BASE + WM_CTLCOLORBTN)
DEFINE OCM_CTLCOLOREDIT       := (OCM__BASE + WM_CTLCOLOREDIT)
DEFINE OCM_CTLCOLORDLG        := (OCM__BASE + WM_CTLCOLORDLG)
DEFINE OCM_CTLCOLORLISTBOX    := (OCM__BASE + WM_CTLCOLORLISTBOX)
DEFINE OCM_CTLCOLORMSGBOX     := (OCM__BASE + WM_CTLCOLORMSGBOX)
DEFINE OCM_CTLCOLORSCROLLBAR  := (OCM__BASE + WM_CTLCOLORSCROLLBAR)
DEFINE OCM_CTLCOLORSTATIC     := (OCM__BASE + WM_CTLCOLORSTATIC)
DEFINE OCM_DRAWITEM        := (OCM__BASE + WM_DRAWITEM)
DEFINE OCM_MEASUREITEM     := (OCM__BASE + WM_MEASUREITEM)
DEFINE OCM_DELETEITEM      := (OCM__BASE + WM_DELETEITEM)
DEFINE OCM_VKEYTOITEM      := (OCM__BASE + WM_VKEYTOITEM)
DEFINE OCM_CHARTOITEM      := (OCM__BASE + WM_CHARTOITEM)
DEFINE OCM_COMPAREITEM     := (OCM__BASE + WM_COMPAREITEM)
DEFINE OCM_HSCROLL         := (OCM__BASE + WM_HSCROLL)
DEFINE OCM_VSCROLL         := (OCM__BASE + WM_VSCROLL)
DEFINE OCM_PARENTNOTIFY    := (OCM__BASE + WM_PARENTNOTIFY)
DEFINE CTRLINFO_EATS_RETURN    := 1
DEFINE CTRLINFO_EATS_ESCAPE    := 2
DEFINE XFORMCOORDS_POSITION            := 0x1
DEFINE XFORMCOORDS_SIZE                := 0x2
DEFINE XFORMCOORDS_HIMETRICTOCONTAINER := 0x4
DEFINE XFORMCOORDS_CONTAINERTOHIMETRIC := 0x8
DEFINE PROPPAGESTATUS_DIRTY    := 0x1
DEFINE PROPPAGESTATUS_VALIDATE := 0x2
DEFINE PICTURE_SCALABLE        := 0x1l
DEFINE PICTURE_TRANSPARENT     := 0x2l
DEFINE PICTYPE_UNINITIALIZED  := DWORD(_CAST, 0xffffffff)
DEFINE PICTYPE_NONE        := 0
DEFINE PICTYPE_BITMAP      := 1
DEFINE PICTYPE_METAFILE    := 2
DEFINE PICTYPE_ICON        := 3
DEFINE DISPID_AUTOSIZE                 := (-500)
DEFINE DISPID_BACKCOLOR                := (-501)
DEFINE DISPID_BACKSTYLE                := (-502)
DEFINE DISPID_BORDERCOLOR              := (-503)
DEFINE DISPID_BORDERSTYLE              := (-504)
DEFINE DISPID_BORDERWIDTH              := (-505)
DEFINE DISPID_DRAWMODE                 := (-507)
DEFINE DISPID_DRAWSTYLE                := (-508)
DEFINE DISPID_DRAWWIDTH                := (-509)
DEFINE DISPID_FILLCOLOR                := (-510)
DEFINE DISPID_FILLSTYLE                := (-511)
DEFINE DISPID_FONT                     := (-512)
DEFINE DISPID_FORECOLOR                := (-513)
DEFINE DISPID_ENABLED                  := (-514)
DEFINE DISPID_HWND                     := (-515)
DEFINE DISPID_TABSTOP                  := (-516)
DEFINE DISPID_TEXT                     := (-517)
DEFINE DISPID_CAPTION                  := (-518)
DEFINE DISPID_BORDERVISIBLE            := (-519)
DEFINE DISPID_REFRESH                  := (-550)
DEFINE DISPID_DOCLICK                  := (-551)
DEFINE DISPID_ABOUTBOX                 := (-552)
DEFINE DISPID_CLICK                    := (-600)
DEFINE DISPID_DBLCLICK                 := (-601)
DEFINE DISPID_KEYDOWN                  := (-602)
DEFINE DISPID_KEYPRESS                 := (-603)
DEFINE DISPID_KEYUP                    := (-604)
DEFINE DISPID_MOUSEDOWN                := (-605)
DEFINE DISPID_MOUSEMOVE                := (-606)
DEFINE DISPID_MOUSEUP                  := (-607)
DEFINE DISPID_ERROREVENT               := (-608)
DEFINE DISPID_AMBIENT_BACKCOLOR        := (-701)
DEFINE DISPID_AMBIENT_DISPLAYNAME      := (-702)
DEFINE DISPID_AMBIENT_FONT             := (-703)
DEFINE DISPID_AMBIENT_FORECOLOR        := (-704)
DEFINE DISPID_AMBIENT_LOCALEID         := (-705)
DEFINE DISPID_AMBIENT_MESSAGEREFLECT   := (-706)
DEFINE DISPID_AMBIENT_SCALEUNITS       := (-707)
DEFINE DISPID_AMBIENT_TEXTALIGN        := (-708)
DEFINE DISPID_AMBIENT_USERMODE         := (-709)
DEFINE DISPID_AMBIENT_UIDEAD           := (-710)
DEFINE DISPID_AMBIENT_SHOWGRABHANDLES  := (-711)
DEFINE DISPID_AMBIENT_SHOWHATCHING     := (-712)
DEFINE DISPID_AMBIENT_DISPLAYASDEFAULT := (-713)
DEFINE DISPID_AMBIENT_SUPPORTSMNEMONICS := (-714)
DEFINE DISPID_AMBIENT_AUTOCLIP          := (-715)
DEFINE DISPID_FONT_NAME    := 0
DEFINE DISPID_FONT_SIZE    := 2
DEFINE DISPID_FONT_BOLD    := 3
DEFINE DISPID_FONT_ITALIC  := 4
DEFINE DISPID_FONT_UNDER   := 5
DEFINE DISPID_FONT_STRIKE  := 6
DEFINE DISPID_FONT_WEIGHT  := 7
DEFINE DISPID_FONT_CHARSET := 8
DEFINE DISPID_PICT_HANDLE  := 0
DEFINE DISPID_PICT_HPAL    := 2
DEFINE DISPID_PICT_TYPE    := 3
DEFINE DISPID_PICT_WIDTH   := 4
DEFINE DISPID_PICT_HEIGHT  := 5
DEFINE DISPID_PICT_RENDER  := 6
DEFINE STDOLE_TLB :=  "stdole32.tlb"
DEFINE STDTYPE_TLB := "oc30d.dll"
#endregion