;License: Public Domain
CompilerIf #PB_Compiler_Unicode = 0
  CompilerError "Should be compiled with Unicode support!"
CompilerEndIf


UsePNGImageDecoder()
UseJPEGImageDecoder()
UseJPEG2000ImageDecoder()
UseTGAImageDecoder()
UseTIFFImageDecoder()

Global Dim buffer.b($FFFF)
Global AllowedExtensions.s
Global MinSize.q
Global MaxSize.q
Global AdditionalImgCategories.i
Global DestFolder.s
Global SrcFolder.s
Global JustCreateIndex.i
Global SortByCreationDate.i
Global KeepPath.i

#WINDOW_WIDTH = 800
#WINDOW_HEIGHT = 700

#GADGET_LOG = 20

#GADGET_STRING_DESTINATION = 1
#GADGET_STRING_SOURCE = 2
#GADGET_STRING_ALLOWED_EXTENSIONS = 3

#GADGET_BUTTON_START = 4
#GADGET_BUTTON_SAVE_TO_FILE = 5

#GADGET_COMBO_MAX = 6
#GADGET_COMBO_MIN = 7

#GADGET_CHECKBOX_ADDITIONAL_IMAGE_CATEGORIES = 8

#GADGET_BUTTON_CLEAR_LOG = 9

#GADGET_CHECKBOX_JUST_INDEX = 10

#GADGET_CHECKBOX_SORTBYDATE = 11

#GADGET_CHECKBOX_KEEP_PATH = 12


#FILE_MD5_WRITE = 100
#FILE_MD5_TEST = 101
#FILE_LOG = 102
#FILE_MD5_CHECK = 103

#FILE_READ = 104
#FILE_WRITE = 105
#FILE_PB_CATEGORY = 106
#FILE_PB_PAINT = 107

Enumeration
  #__LIB_SPRITE 
  #__LIB_GADGET 
  #__LIB_WINDOW
  #__LIB_DRAWING     
  #__LIB_CHIPER 
  #__LIB_AUDIOCD 
  #__LIB_CLIPBOARD
  #__LIB_CONSOLE
  #__LIB_DATABASE
  #__LIB_DATE 
  #__LIB_DESKTOP 
  #__LIB_DRAGDROP 
  #__LIB_FILE
  #__LIB_FILESYSTEM 
  #__LIB_FTP 
  #__LIB_FONT 
  #__LIB_HELP 
  #__LIB_HTTP
  #__LIB_IMAGE 
  #__LIB_LIBRARY 
  #__LIB_LINKEDLIST 
  #__LIB_MAIL 
  #__LIB_MAP 
  #__LIB_MATH 
  #__LIB_MEMORY 
  #__LIB_MENU
  #__LIB_MISC
  #__LIB_MOVIE
  #__LIB_NETWORK 
  #__LIB_ONERROR 
  #__LIB_PACKER
  #__LIB_PREF 
  #__LIB_PRINTER
  #__LIB_PROCESS 
  #__LIB_REGEXP 
  #__LIB_REQUESTER
  #__LIB_SCINTILLA
  #__LIB_SERIAL
  #__LIB_SORT
  #__LIB_STATUSBAR
  #__LIB_STRING
  #__LIB_SYSTEM
  #__LIB_SYSTRAY
  #__LIB_THREAD
  #__LIB_TOOLBAR
  #__LIB_XML 
  #__LIB_JOYSTICK 
  #__LIB_KEYBOARD
  #__LIB_MODULE
  #__LIB_MOUSE 
  #__LIB_PALETTE 
  #__LIB_SPRITE3D
  #__LIB_SOUND 
  #__LIB_ENGINE3D 
  #__LIB_WINDOW3D 
  #__LIB_GADGET3D 
  #__LIB_SOUND3D 
  #__LIB_COM
  #__LIB_DLL
  #__LIB_API
  #__LIB_DIRECTX
  #__LIB_ASSEMBLER
  #__LIB_MCI
  #__LIB_OPENGL
  #__LIB_END
EndEnumeration




Global pb_lib_list.s = "Sprite,Gadget,Window,Drawing,Chiper,AudioCD,Clipboard,Console,Database,Date,Desktop,DragDrop,File,File-System,FTP,Font,Help,HTTP,Image,Library,LinkedList,Mail,Map,Math,Memory,Menu,Misc,Movie,Network,OnError,Packer,Prefs,Printer,Process,RegExp,Requester,Scintilla,Serial,Sort,Statusbar,String,System,Systray,Thread,Toolbar,XML,Joystick,Keyboard,Module,Mouse,Palette,Sprite3D,Sound,Engine3D,Window3D,Gadget3D,Sound3D,COM,DLL,API,DirectX,Assembler,MCI,OpenGL"
Global pb_lib_list_upper.s = "Graphics,Userinterface,Userinterface,Graphics,Chiper,Audio,Userinterface,Userinterface,IO,Other,Userinterface,Userinterface,IO,IO,IO,Userinterface,Userinterface,IO,Graphics,IO,Other,IO,Other,Other,Other,Userinterface,Other,Graphics,IO,Other,IO,IO,IO,System,Other,Userinterface,Userinterface,IO,Other,Userinterface,Other,System,Userinterface,System,Userinterface,IO,Input,Input,Audio,Input,Graphics,Graphics,Audio,Graphics,Userinterface,Userinterface,Audio,System,Other,System,Graphics,System,Audio,Graphics"

Structure PBLIB
  libId.i
  points.i
EndStructure  

Procedure ErrorHandler()
  
  ErrorMessage$ = "A program error was detected:" + Chr(13) 
  ErrorMessage$ + Chr(13)
  ErrorMessage$ + "Error Message:   " + ErrorMessage()      + Chr(13)
  ErrorMessage$ + "Error Code:      " + Hex(ErrorCode())    + Chr(13)  
  ErrorMessage$ + "Code Address:    " + Hex(ErrorAddress()) + Chr(13)
  
  If ErrorCode() = #PB_OnError_InvalidMemory   
    ErrorMessage$ + "Target Address:  " + Str(ErrorTargetAddress()) + Chr(13)
  EndIf
  
  ErrorMessage$ + "Sourcecode line: " + Str(ErrorLine()) + Chr(13)
  ErrorMessage$ + "Sourcecode file: " + ErrorFile() + Chr(13)
  
  ErrorMessage$ + Chr(13)
  
  MessageRequester("OnError example", ErrorMessage$)
  End
  
EndProcedure


OnErrorCall(@ErrorHandler())


Procedure.s Fit(dir.s)
  If Right(dir,1)<> "\"
    dir = dir + "\"
  EndIf
  ProcedureReturn dir
EndProcedure  


Procedure SelectFileGadget(Id, x, y, width, text$, def$)
  TextGadget(#PB_Any, x, y,      width, 21, text$)
  StringGadget(Id,    x, y + 21, width-21, 21, def$,  #PB_String_ReadOnly )
  ButtonGadget(1000+Id, x + width - 21, y + 21, 21,21 , "...")
EndProcedure


Procedure EndApp()
  End
EndProcedure  

Procedure LogOut(text.s)
  If IsGadget(#GADGET_LOG)
    AddGadgetItem(#GADGET_LOG, -1, text)  
  EndIf  
EndProcedure  

Procedure FillWithSizes(gadget)
  AddGadgetItem(gadget, 0,"*")    
  AddGadgetItem(gadget, 1,"1 Byte")
  AddGadgetItem(gadget, 2,"1 KB")
  AddGadgetItem(gadget, 3,"100 KB")
  AddGadgetItem(gadget, 4,"1 MB")
  AddGadgetItem(gadget, 5,"10 MB")
  AddGadgetItem(gadget, 6,"100 MB")
  AddGadgetItem(gadget, 7,"1 GB")
  SetGadgetState(gadget, 0)
EndProcedure  

Procedure.q GetSize(gadget,IsMinimum)
  state = GetGadgetState(gadget)
  Select state
    Case 0
      If IsMinimum
        ProcedureReturn 0
      Else
        ProcedureReturn 1 << 62
      EndIf  
    Case 1
      ProcedureReturn 1
    Case 2
      ProcedureReturn 1024
    Case 3
      ProcedureReturn 100 * 1024
    Case 4
      ProcedureReturn 1024 * 1024 
    Case 5
      ProcedureReturn 10 * 1024 * 1024       
    Case 6
      ProcedureReturn 100 * 1024 * 1024
    Case 7
      ProcedureReturn 1024 * 1024 * 1024  
    Default
      LogOut("ERROR: invalid value for size. Index: " +Str(state))
  EndSelect
EndProcedure 

Procedure IsAllowedExtension(ext.s)
  If Len(AllowedExtensions) = 0:ProcedureReturn #True:EndIf
  
  count = CountString(AllowedExtensions.s, ",") + 1
  For i = 1 To count
    If UCase(ext) = StringField(AllowedExtensions, i, ",")
      ProcedureReturn #True
    EndIf
    
    If StringField(AllowedExtensions, i, ",") = "NONE" And ext = ""
      ProcedureReturn #True
    EndIf  
  Next  
  ProcedureReturn #False
EndProcedure  

Procedure UpdateParameters()
  AllowedExtensions = UCase(Trim(GetGadgetText(#GADGET_STRING_ALLOWED_EXTENSIONS)))
  MinSize.q = GetSize(#GADGET_COMBO_MIN,#True)
  MaxSize.q = GetSize(#GADGET_COMBO_MAX,#False) 
  AdditionalImgCategories = GetGadgetState(#GADGET_CHECKBOX_ADDITIONAL_IMAGE_CATEGORIES)
  DestFolder.s = GetGadgetText(#GADGET_STRING_DESTINATION)
  SrcFolder.s= GetGadgetText(#GADGET_STRING_SOURCE)
  JustCreateIndex = GetGadgetState(#GADGET_CHECKBOX_JUST_INDEX)
  SortByCreationDate = GetGadgetState(#GADGET_CHECKBOX_SORTBYDATE)
  
  KeepPath = GetGadgetState(#GADGET_CHECKBOX_KEEP_PATH)  
EndProcedure

Procedure ProcessDialog(event)
  If event = #PB_Event_Gadget
    If EventGadget() > 1000     
      result.s = PathRequester("Select folder to check...", "")
      If result <> "" And result <> "\"
        SetGadgetText(EventGadget() - 1000, Fit(result))
      EndIf  
      
    EndIf  
  EndIf
EndProcedure  

Procedure SimpleMessageProcess()
  Repeat
    event = WindowEvent()
    
    If event = #PB_Event_Gadget
      If EventGadget() = #GADGET_BUTTON_CLEAR_LOG
        ClearGadgetItems(#GADGET_LOG)
      EndIf  
    EndIf
    If event = #PB_Event_CloseWindow:EndApp():EndIf
  Until event = 0  
EndProcedure  

Procedure.s MD5OfFile(file.s)
  Protected sz.q, pos.q, length.q, ok = #True, MD5$=""
  If ReadFile(#FILE_MD5_CHECK, file)
    length.q = Lof(#FILE_MD5_CHECK)
    If ExamineMD5Fingerprint(1)
      
      While (pos < length) And ok = #True
        
        StatusBarProgress(0, 1, Int((pos * 100.0) / (length * 1.0)),#PB_StatusBar_Raised ,0,100)
        
        SimpleMessageProcess()
        FileSeek(#FILE_MD5_CHECK, pos)
        
        sz = (length - pos)
        If sz > $FFFF:sz = $FFFF:EndIf
        
        result = ReadData(#FILE_MD5_CHECK, @buffer(0), sz)
        
        If result > 0
          NextFingerprint(1, @buffer(0), result)
        Else
          LogOut("ERROR: IO read error at position " + Hex(pos) + " in file '" + file.s + "'")
          ok = #False
        EndIf 
        pos + sz  
      Wend
      If ok
        MD5$ = FinishFingerprint(1)
      EndIf
    Else
      LogOut("ERROR: Internal MD5 function error")
    EndIf
    CloseFile(#FILE_MD5_CHECK)  
  Else
    LogOut("ERROR: Cannot open file '"+file+"'")    
  EndIf
  ProcedureReturn MD5$
EndProcedure 

#FILE_READ = 104
#FILE_WRITE = 105
Procedure.s CopyFileMsgProcess(src.s, dst.s)
  Protected sz.q, pos.q, length.q, ok = #True, MD5$=""
  If ReadFile(#FILE_READ, src)
    
    If CreateFile(#FILE_WRITE, dst)
      length.q = Lof(#FILE_READ)
      
      While (pos < length) And ok = #True
        
        StatusBarProgress(0, 1, Int((pos * 100.0) / (length * 1.0)),#PB_StatusBar_Raised ,0,100)
        
        SimpleMessageProcess()
        FileSeek(#FILE_READ, pos)
        
        sz = (length - pos)
        If sz > $FFFF:sz = $FFFF:EndIf
        
        result = ReadData(#FILE_MD5_CHECK, @buffer(0), sz)
        
        If result > 0
          If WriteData(#FILE_WRITE, @buffer(0), result) <> result
            LogOut("ERROR: IO write error at position " + Hex(pos) + " in file '" + dst.s + "'")            
            ok = #False
          EndIf  
        Else
          LogOut("ERROR: IO read error at position " + Hex(pos) + " in file '" + src.s + "'")
          ok = #False
        EndIf 
        pos + sz  
      Wend
      CloseFile(#FILE_WRITE)
    Else
      LogOut("ERROR: Cannot open destinaiton file '"+dst+"'")      
    EndIf  
    CloseFile(#FILE_READ)
  Else
    LogOut("ERROR: Cannot open source file '"+src+"'")    
  EndIf
  ProcedureReturn MD5$
EndProcedure 



Procedure index_contains_MD5(MD5$)
  Protected found = #False
  If ReadFile(#FILE_MD5_TEST, DestFolder + "md5-index-list\"+Left(MD5$, 3))
    Repeat
      line.s = ReadString(#FILE_MD5_TEST)
      If line = MD5$ 
        found = #True
      EndIf  
    Until Eof(#FILE_MD5_TEST) Or found = #True  
    CloseFile(#FILE_MD5_TEST)
  EndIf  
  ProcedureReturn found
EndProcedure  

Procedure index_add_MD5(MD5$)
  Protected found = #False
  CreateDirectory(DestFolder + "md5-index-list\")
  If OpenFile(#FILE_MD5_WRITE, DestFolder + "md5-index-list\"+Left(MD5$, 3))
    FileSeek(#FILE_MD5_WRITE, Lof(#FILE_MD5_WRITE)) 
    WriteStringN(#FILE_MD5_WRITE, MD5$)
    CloseFile(#FILE_MD5_WRITE)
  Else
    LogOut("ERROR: Cannot create index file '" + DestFolder + "md5-index-list\"+Left(MD5$, 3) + "'")
  EndIf  
EndProcedure  


Procedure Check(text.s, strings.s, IsFunction)
  
  If IsFunction And FindString(text, "(") = 0:ProcedureReturn 0:EndIf ; Speed optimisation
  strings.s = UCase(strings)
  count = CountString(strings, ",") + 1
  For i = 1 To count
    If IsFunction
      If FindString(text, StringField(strings, i, ",")+"(" ):ProcedureReturn 1:EndIf
    Else
      If FindString(text, StringField(strings, i, ",")):ProcedureReturn 1:EndIf      
    EndIf  
  Next  
  ProcedureReturn 0
EndProcedure  

Procedure.s get_pb_file_category(file.s)
  Dim libs.PBLIB(#__LIB_END-1)
  For i = 0 To #__LIB_END-1
    libs(i)\libId = i+1
  Next
  
  If ReadFile(#FILE_PB_CATEGORY, file)
    Repeat
      
      If linecount % 10 = 0
        linecount + 1
        SimpleMessageProcess()
      EndIf  
      
      line.s = UCase(Trim(ReadString(#FILE_PB_CATEGORY)))
      libs(#__LIB_SPRITE)\points + 2 * Check(line, "CatchSprite,ClearScreen,ClipSprite,CloseScreen,CopySprite,CreateSprite,DisplayRGBFilter,DisplaySprite,DisplayTransparentSprite,ExamineScreenModes,FlipBuffers,FreeSprite,GrabSprite,InitSprite,IsScreenActive,IsSprite,LoadSprite,NextScreenMode,OpenScreen,OpenWindowedScreen,SaveSprite,ScreenDepth,ScreenHeight,ScreenID,ScreenModeDepth,ScreenModeHeight,ScreenModeRefreshRate,ScreenModeWidth,ScreenOutput,ScreenWidth,SetFrameRate,SpriteCollision,SpriteDepth,SpriteHeight,SpriteID,SpriteOutput,SpritePixelCollision,SpriteWidth,TransparentSpriteColor,UseBuffer",#True)
      libs(#__LIB_GADGET)\points + 1 * Check(line, "SendMessage_,AddGadgetColumn,AddGadgetItem,ButtonGadget,ButtonImageGadget,CalendarGadget,CanvasGadget,CanvasOutput,ChangeListIconGadgetDisplay,CheckBoxGadget,ClearGadgetItemList,ClearGadgetItems,CloseGadgetList,ComboBoxGadget,ContainerGadget,CountGadgetItems,CreateGadgetList,DateGadget,DisableGadget,EditorGadget,ExplorerComboGadget,ExplorerListGadget,ExplorerTreeGadget,Frame3DGadget,FreeGadget,GadgetHeight,GadgetID,GadgetItemID,GadgetToolTip,GadgetType,GadgetWidth,GadgetX,GadgetY,GetActiveGadget,GetGadgetAttribute,GetGadgetColor,GetGadgetData,GetGadgetFont,GetGadgetItemAttribute,GetGadgetItemColor,GetGadgetItemData,GetGadgetItemState,GetGadgetItemText,GetGadgetState,GetGadgetText,HideGadget,HyperLinkGadget,IPAddressGadget,ImageGadget,IsGadget,ListIconGadget,ListViewGadget,MDIGadget,OpenGadgetList,OptionGadget,PanelGadget,ProgressBarGadget,RemoveGadgetColumn,RemoveGadgetItem,ResizeGadget,ScrollAreaGadget,ScrollBarGadget,SetActiveGadget,SetGadgetAttribute,SetGadgetColor,SetGadgetData,SetGadgetFont,SetGadgetItemAttribute,SetGadgetItemColor,SetGadgetItemData,SetGadgetItemImage,SetGadgetItemState,SetGadgetItemText,SetGadgetState,SetGadgetText,ShortcutGadget,SpinGadget,SplitterGadget,StringGadget,TextGadget,TrackBarGadget,TreeGadget,UseGadgetList,WebGadget",#True)
      
      libs(#__LIB_WINDOW)\points + 1 * Check(line, "SetWindowPos_,AddKeyboardShortcut,AddWindowTimer,CloseWindow,DisableWindow,EventData,EventGadget,EventMenu,EventTimer,EventType,EventWindow,GetActiveWindow,GetWindowColor,GetWindowState,GetWindowTitle,HideWindow,IsWindow,OpenWindow,PostEvent,RemoveKeyboardShortcut,RemoveWindowTimer,ResizeWindow,SetActiveWindow,SetWindowCallback,SetWindowColor,SetWindowState,SetWindowTitle,SmartWindowRefresh,StickyWindow,WaitWindowEvent,WindowBounds,WindowEvent,WindowHeight,WindowID,WindowMouseX,WindowMouseY,WindowOutput,WindowWidth,WindowX,WindowY",#True)
      libs(#__LIB_DRAWING)\points + 16 * Check(line, "BackColor,Box,BoxedGradient,Circle,CircularGradient,ConicalGradient,CustomFilterCallback,CustomGradient,DrawAlphaImage,DrawImage,DrawRotatedText,DrawText,DrawingBuffer,DrawingBufferPitch,DrawingBufferPixelFormat,DrawingFont,DrawingMode,Ellipse,EllipticalGradient,FillArea,FrontColor,GrabDrawingImage,GradientColor,Line,LineXY,LinearGradient,OutputDepth,OutputHeight,OutputWidth,Plot,Point,ResetGradientColors,RoundBox,StartDrawing,StopDrawing,TextHeight,TextWidth",#True)
      libs(#__LIB_DRAWING)\points + 16 * Check(line, "CreateBitmap_,CreateCompatibleBitmap_,CreateCompatibleDC_,PlgBlt_,SetPixelV_,GetPixel_,SetPixel_,BitBlt_,StrechBlt_,Alpha,AlphaBlend,Blue,Green,RGB,RGBA,Red",#True)      
      libs(#__LIB_DRAWING)\points + 16 * Check(line, "GetDC_,ReleaseDC_,CreateDC_,GetStockObject_,MoveToEx_,LineTo_,PolyPolyline_,PolyDraw_,GdiTransparentBlt_,GetBitmapBits_,SetStretchBltMode_,StretchDIBits_,TransparentBlt_,GradientFill_,MaskBlt_,ExtFloodFill_,FloodFill_,SetDIBitsToDevice_",#True)      
      
      libs(#__LIB_CHIPER)\points + 16 * Check(line, "AESDecoder,AESEncoder,AddCipherBuffer,Base64Decoder,Base64Encoder,CRC32FileFingerprint,CRC32Fingerprint,CloseCryptRandom,CryptRandom,CryptRandomData,DESFingerprint,ExamineMD5Fingerprint,ExamineSHA1Fingerprint,FinishCipher,FinishFingerprint,IsFingerprint,MD5FileFingerprint,MD5Fingerprint,NextFingerprint,OpenCryptRandom,SHA1FileFingerprint,SHA1Fingerprint,StartAESCipher",#True)
      libs(#__LIB_AUDIOCD)\points + 16 * Check(line, "AudioCDLength,AudioCDName,AudioCDStatus,AudioCDTrackLength,AudioCDTrackSeconds,AudioCDTracks,EjectAudioCD,InitAudioCD,PauseAudioCD,PlayAudioCD,ResumeAudioCD,StopAudioCD,UseAudioCD",#True)
      libs(#__LIB_CLIPBOARD)\points + 16 * Check(line, "ClearClipboard,GetClipboardImage,GetClipboardText,SetClipboardImage,SetClipboardText",#True)
      libs(#__LIB_CONSOLE)\points + 16 *  Check(line, "ClearConsole,CloseConsole,ConsoleColor,ConsoleCursor,ConsoleError,ConsoleLocate,ConsoleTitle,EnableGraphicalConsole,Inkey,Input,OpenConsole,Print,PrintN,RawKey,ReadConsoleData,WriteConsoleData", #True)
      libs(#__LIB_DATABASE)\points+ 16 * Check(line, "AffectedDatabaseRows,CheckDatabaseNull,CloseDatabase,DatabaseColumnIndex,DatabaseColumnName,DatabaseColumnSize,DatabaseColumnType,DatabaseColumns,DatabaseDriverDescription,DatabaseDriverName,DatabaseError,DatabaseID,DatabaseQuery,DatabaseUpdate,ExamineDatabaseDrivers,FinishDatabaseQuery,FirstDatabaseRow,GetDatabaseBlob,GetDatabaseDouble,GetDatabaseFloat,GetDatabaseLong,GetDatabaseQuad,GetDatabaseString,IsDatabase,NextDatabaseDriver,NextDatabaseRow,OpenDatabase,OpenDatabaseRequester,PreviousDatabaseRow,SetDatabaseBlob,UseODBCDatabase,UsePostgreSQLDatabase,UseSQLiteDatabase",#True)
      libs(#__LIB_DATE)\points + 4 * Check(line, "AddDate,Date,Day,DayOfWeek,DayOfYear,FormatDate,Hour,Minute,Month,ParseDate,Second,Year",#True)
      libs(#__LIB_DESKTOP)\points + 8 * Check(line, "DesktopDepth,DesktopFrequency,DesktopHeight,DesktopMouseX,DesktopMouseY,DesktopName,DesktopWidth,DesktopX,DesktopY,ExamineDesktops",#True)
      libs(#__LIB_DRAGDROP)\points + 16 * Check(line, "DragFiles,DragImage,DragOSFormats,DragPrivate,DragText,EnableGadgetDrop,EnableWindowDrop,EventDropAction,EventDropBuffer,EventDropFiles,EventDropImage,EventDropPrivate,EventDropSize,EventDropText,EventDropType,EventDropX,EventDropY,SetDragCallback,SetDropCallback",#True)
      libs(#__LIB_FILE)\points + 4 * Check(line, "CloseFile,CreateFile,Eof,FileBuffersSize,FileID,FileSeek,FlushFileBuffers,IsFile,Loc,Lof,OpenFile,ReadAsciiCharacter,ReadByte,ReadCharacter,ReadData,ReadDouble,ReadFile,ReadFloat,ReadInteger,ReadLong,ReadQuad,ReadString,ReadStringFormat,ReadUnicodeCharacter,ReadWord,TruncateFile,WriteAsciiCharacter,WriteByte,WriteCharacter,WriteData,WriteDouble,WriteFloat,WriteInteger,WriteLong,WriteQuad,WriteString,WriteStringFormat,WriteStringN,WriteUnicodeCharacter,WriteWord",#True)
      
      libs(#__LIB_FILESYSTEM)\points + 8 * Check(line, "CheckFilename,CopyDirectory,CopyFile,CreateDirectory,DeleteDirectory,DeleteFile,DirectoryEntryAttributes,DirectoryEntryDate,DirectoryEntryName,DirectoryEntrySize,DirectoryEntryType,ExamineDirectory,FileSize,FinishDirectory,GetCurrentDirectory,GetExtensionPart,GetFileAttributes,GetFileDate,GetFilePart,GetHomeDirectory,GetPathPart,GetTemporaryDirectory,IsDirectory,NextDirectoryEntry,RenameFile,SetCurrentDirectory,SetFileAttributes,SetFileDate",#True)
      libs(#__LIB_FTP)\points + 16 * Check(line, "AbortFTPFile,CheckFTPConnection,CloseFTP,CreateFTPDirectory,DeleteFTPDirectory,DeleteFTPFile,ExamineFTPDirectory,FTPDirectoryEntryAttributes,FTPDirectoryEntryDate,FTPDirectoryEntryName,FTPDirectoryEntryRaw,FTPDirectoryEntrySize,FTPDirectoryEntryType,FTPProgress,FinishFTPDirectory,GetFTPDirectory,IsFtp,NextFTPDirectoryEntry,OpenFTP,ReceiveFTPFile,RenameFTPFile,SendFTPFile,SetFTPDirectory",#True)
      libs(#__LIB_FONT)\points + 8 * Check(line, "FontID,FreeFont,IsFont,LoadFont",#True)
      libs(#__LIB_HELP)\points + 16 * Check(line, "CloseHelp,OpenHelp",#True)
      libs(#__LIB_HTTP)\points + 16 * Check(line, "GetHTTPHeader,GetURLPart,ReceiveHTTPFile,SetURLPart,URLDecoder,URLEncoder,URLDownloadToFile_,InternetOpen_,InternetOpenUrl_,InternetReadFile_",#True)
      libs(#__LIB_HTTP)\points + 16 * Check(line, "#INTERNET_,#WINHTTP_",#False)
      
      
      libs(#__LIB_IMAGE)\points + 4 * Check(line, "CatchImage,CopyImage,CreateImage,EncodeImage,FreeImage,GrabImage,ImageDepth,ImageFormat,ImageHeight,ImageID,ImageOutput,ImageWidth,IsImage,LoadImage,ResizeImage,SaveImage,UseJPEG2000ImageDecoder,UseJPEG2000ImageEncoder,UseJPEGImageDecoder,UseJPEGImageEncoder,UsePNGImageDecoder,UsePNGImageEncoder,UseTGAImageDecoder,UseTIFFImageDecoder",#True)      
      libs(#__LIB_LIBRARY)\points + 4 * Check(line, "LoadLibrary_,GetProcAddress_,FreeLibrary_,CallCFunction,CallCFunctionFast,CallFunction,CallFunctionFast,CloseLibrary,CountLibraryFunctions,ExamineLibraryFunctions,GetFunction,GetFunctionEntry,IsLibrary,LibraryFunctionAddress,LibraryFunctionName,LibraryID,NextLibraryFunction,OpenLibrary",#True)
      libs(#__LIB_LINKEDLIST)\points + 2 * Check(line,"AddElement,ChangeCurrentElement,ClearList,CopyList,CountList,DeleteElement,FirstElement,FreeList,InsertElement,LastElement,ListIndex,ListSize,MergeLists,MoveElement,NextElement,PopListPosition,PreviousElement,PushListPosition,ResetList,SelectElement,SplitList,SwapElements",#True)
      
      libs(#__LIB_MAIL)\points + 16  * Check(line,"AddMailAttachment,AddMailAttachmentData,AddMailRecipient,CreateMail,FreeMail,GetMailAttribute,GetMailBody,IsMail,MailProgress,RemoveMailRecipient,SendMail,SetMailAttribute,SetMailBody",#True)
      libs(#__LIB_MAP)\points + 2 * Check(line,"AddMapElement,ClearMap,CopyMap,DeleteMapElement,FindMapElement,FreeMap,MapKey,MapSize,NextMapElement,PopMapPosition,PushMapPosition,ResetMap",#True)
      libs(#__LIB_MATH)\points + 4 * Check(line, "ACos,ACosH,ASin,ASinH,ATan,ATan2,ATanH,Abs,Cos,CosH,Degree,Exp,Infinity,Int,IntQ,IsInfinity,IsNaN,Log,Log10,Mod,NaN,Pow,Radian,Round,Sign,Sin,SinH,Sqr,Tan,TanH",#True)
      libs(#__LIB_MATH)\points + 4 * Check(line, "#PI,#E,2.718,3.141",#False)      
      libs(#__LIB_MEMORY)\points + 4 * Check(line, "AllocateMemory,CompareMemory,CompareMemoryString,CopyMemory,CopyMemoryString,FillMemory,FreeMemory,MemorySize,MemoryStringLength,MoveMemory,PeekA,PeekB,PeekC,PeekD,PeekF,PeekI,PeekL,PeekQ,PeekS,PeekU,PeekW,PokeA,PokeB,PokeC,PokeD,PokeF,PokeI,PokeL,PokeQ,PokeS,PokeU,PokeW,ReAllocateMemory",#True)
      libs(#__LIB_MEMORY)\points + 4 * Check(line, "AllocateUserPhysicalPages_,CopyMemory_,CreateFileMapping_,FillMemory_,FlushViewOfFile_,FreeUserPhysicalPages_,GetLargePageMinimum_,GetMemoryErrorHandlingCapabilities_,GetPhysicallyInstalledSystemMemory_,GetProcessHeap_,GetProcessHeaps_,GetSystemFileCacheSize_,GetWriteWatch_,GlobalAlloc_,GlobalDiscard_,GlobalFlags_,GlobalFree_,GlobalHandle_,GlobalLock_,GlobalMemoryStatus_,GlobalMemoryStatusEx_,GlobalReAlloc_,GlobalSize_,GlobalUnlock_,HeapAlloc_,HeapCompact_,HeapCreate_,HeapDestroy_,HeapFree_,HeapLock_,HeapQueryInformation_,HeapReAlloc_,HeapSetInformation_,HeapSize_,HeapUnlock_,HeapValidate_,HeapWalk_,IsBadCodePtr_,IsBadReadPtr_,IsBadStringPtr_,IsBadWritePtr_,LocalAlloc_,LocalDiscard_,LocalFlags_,LocalFree_,LocalHandle_,LocalLock_,LocalReAlloc_,LocalSize_,LocalUnlock_,MapViewOfFile_,MapViewOfFileEx_,MoveMemory_,OpenFileMapping_,SecureZeroMemory_,SetSystemFileCacheSize_,UnmapViewOfFile_,VirtualAlloc_,VirtualAllocEx_,VirtualFree_,VirtualFreeEx_,VirtualLock_,VirtualProtect_,VirtualProtectEx_,VirtualQuery_,VirtualQueryEx_,VirtualUnlock_,ZeroMemory_",#True)
      
      libs(#__LIB_MENU)\points + 16 * Check(line, "CloseSubMenu,CreateImageMenu,CreateMenu,CreatePopupImageMenu,CreatePopupMenu,DisableMenuItem,DisplayPopupMenu,FreeMenu,GetMenuItemState,GetMenuItemText,GetMenuTitleText,HideMenu,IsMenu,MenuBar,MenuHeight,MenuID,MenuItem,MenuTitle,OpenSubMenu,SetMenuItemState,SetMenuItemText,SetMenuTitleText",#True)   
      libs(#__LIB_MISC)\points + 16 * Check(line, "CocoaMessage,Random,RandomData,RandomSeed",#True)
      
      libs(#__LIB_MOVIE)\points + 8  * Check(line, "FreeMovie,InitMovie,IsMovie,LoadMovie,MovieAudio,MovieHeight,MovieInfo,MovieLength,MovieSeek,MovieStatus,MovieWidth,PauseMovie,PlayMovie,RenderMovieFrame,ResizeMovie,ResumeMovie,StopMovie",#True)
      
      libs(#__LIB_NETWORK)\points + 8 *Check(line, "CloseNetworkConnection,CloseNetworkServer,ConnectionID,CreateNetworkServer,EventClient,EventServer,ExamineIPAddresses,FreeIP,GetClientIP,GetClientPort,HostName,IPAddressField,IPString,InitNetwork,MakeIPAddress,NetworkClientEvent,NetworkServerEvent,NextIPAddress,OpenNetworkConnection,ReceiveNetworkData,SendNetworkData,SendNetworkString,ServerID",#True)
      libs(#__LIB_NETWORK)\points + 8 * Check(line, "#PB_Network_TCP,#PB_Network_UDP,#PB_Network_IPv4,#PB_Network_IPv6",#False)
      libs(#__LIB_NETWORK)\points + 8 * Check(line, "accept_,AcceptEx_,bind_,closesocket_,connect_,ConnectEx_,DisconnectEx_,EnumProtocols_,freeaddrinfo_,FreeAddrInfoW_,FreeAddrInfoEx_,gai_strerror_,GetAcceptExSockaddrs_,GetAddressByName_,getaddrinfo_,GetAddrInfoEx_,GetAddrInfoExCancel_,GetAddrInfoExOverlappedResult_,GetAddrInfoW_,gethostbyaddr_,gethostbyname_,gethostname_,GetNameByType_,getnameinfo_,GetNameInfoW_,getpeername_,getprotobyname_,getprotobynumber_,getservbyname_,getservbyport_,GetService_,getsockname_,getsockopt_,GetTypeByName_,htond_,htonf_,htonl_,htonll_,htons_,inet_addr_,inet_ntoa_,InetNtop_,InetPton_,ioctlsocket_,listen_,ntohd_,ntohf_,ntohl_,ntohll_,ntohs_,recv_,recvfrom_,Select_,send_,sendto_,SetAddrInfoEx_,SetService_,SetSocketMediaStreamingMode_,setsockopt_,shutdown_,socket_,TransmitFile_,TransmitPackets_,WSAAccept_,WSAAddressToString_,WSAAsyncGetHostByAddr_,WSAAsyncGetHostByName_,WSAAsyncGetProtoByName_,WSAAsyncGetProtoByNumber_,WSAAsyncGetServByName_,WSAAsyncGetServByPort_,WSAAsyncSelect_,WSACancelAsyncRequest_,WSACancelBlockingCall_,WSACleanup_,WSACloseEvent_,WSAConnect_,WSAConnectByList_,WSAConnectByName_,WSACreateEvent_,WSADeleteSocketPeerTargetName_,WSADuplicateSocket_,WSAEnumNameSpaceProviders_,WSAEnumNameSpaceProvidersEx_,WSAEnumNetworkEvents_,WSAEnumProtocols_,WSAEventSelect_,WSAGetLastError_,WSAGetOverlappedResult_,WSAGetQOSByName_,WSAGetServiceClassInfo_,WSAGetServiceClassNameByClassId_,WSAHtonl_,WSAHtons_,WSAImpersonateSocketPeer_,WSAInstallServiceClass_,WSAIoctl_,WSAIsBlocking_,WSAJoinLeaf_,WSALookupServiceBegin_,WSALookupServiceEnd_,WSALookupServiceNext_,WSANSPIoctl_,WSANtohl_,WSANtohs_,WSAPoll_,WSAQuerySocketSecurity_,WSAProviderConfigChange_,WSARecv_,WSARecvDisconnect_,WSARecvEx_,WSARecvFrom_,WSARecvMsg_,WSARemoveServiceClass_,WSAResetEvent_,WSARevertImpersonation_,WSASend_,WSASendDisconnect_,WSASendMsg_,WSASendTo_,WSASetBlockingHook_,WSASetEvent_,WSASetLastError_,WSASetService_,WSASetSocketPeerTargetName_,WSASetSocketSecurity_,WSASocket_,WSAStartup_,WSAStringToAddress_,WSAWaitForMultipleEvents",#True)
      
      libs(#__LIB_ONERROR)\points + 16 * Check(line, "ErrorAddress,ErrorCode,ErrorFile,ErrorLine,ErrorMessage,ErrorRegister,ErrorTargetAddress,ExamineAssembly,InstructionAddress,InstructionString,NextInstruction,OnErrorCall,OnErrorDefault,OnErrorExit,OnErrorGoto,RaiseError",#True)
      
      libs(#__LIB_PACKER)\points + 8 * Check(line, "AddPackFile,AddPackMemory,ClosePack,CompressMemory,CreatePack,ExaminePack,NextPackEntry,OpenPack,PackEntryName,PackEntrySize,PackEntryType,RemovePackFile,UncompressMemory,UncompressPackFile,UncompressPackMemory,UseBriefLZPacker,UseJCALG1Packer,UseLZMAPacker,UseZipPacker",#True)
      
      libs(#__LIB_PREF)\points + 8 * Check(line, "ClosePreferences,CreatePreferences,ExaminePreferenceGroups,ExaminePreferenceKeys,NextPreferenceGroup,NextPreferenceKey,OpenPreferences,PreferenceComment,PreferenceGroup,PreferenceGroupName,PreferenceKeyName,PreferenceKeyValue,ReadPreferenceDouble,ReadPreferenceFloat,ReadPreferenceInteger,ReadPreferenceLong,ReadPreferenceQuad,ReadPreferenceString,RemovePreferenceGroup,RemovePreferenceKey,WritePreferenceDouble,WritePreferenceFloat,WritePreferenceInteger,WritePreferenceLong,WritePreferenceQuad,WritePreferenceString",#True)
      libs(#__LIB_PRINTER)\points + 8 * Check(line, "DefaultPrinter,NewPrinterPage,PrintRequester,PrinterOutput,PrinterPageHeight,PrinterPageWidth,StartPrinting,StopPrinting",#True)
      
      libs(#__LIB_PROCESS)\points + 4 * Check(line, "ShellExecute_,ShellExecuteEx_,AvailableProgramOutput,CloseProgram,CountProgramParameters,EnvironmentVariableName,EnvironmentVariableValue,ExamineEnvironmentVariables,GetEnvironmentVariable,IsProgram,KillProgram,NextEnvironmentVariable,ProgramExitCode,ProgramFilename,ProgramID,ProgramParameter,ProgramRunning,ReadProgramData,ReadProgramError,ReadProgramString,RemoveEnvironmentVariable,RunProgram,SetEnvironmentVariable,WaitProgram,WriteProgramData,WriteProgramString,WriteProgramStringN",#True)
      libs(#__LIB_PROCESS)\points + 4 * Check(line, "AssignProcessToJobObject_,BindIoCompletionCallback_,CallbackMayRunLong_,CreateJobObject_,CreateProcess_,CreateProcessAsUser_,CreateProcessWithLogonW_,CreateProcessWithTokenW_",#True)
      libs(#__LIB_PROCESS)\points + 4 * Check(line, "ExitProcess_,FlushProcessWriteBuffers_,FreeEnvironmentStrings_,GetCommandLine_,GetCurrentProcess_,GetCurrentProcessId_,GetCurrentProcessorNumber_,GetCurrentProcessorNumberEx_,GetEnvironmentStrings_,GetEnvironmentVariable_,GetExitCodeProcess_,GetGuiResources_,GetLogicalProcessorInformation_,GetLogicalProcessorInformationEx_,GetMaximumProcessorCount_,GetMaximumProcessorGroupCount_,GetPriorityClass_,GetProcessAffinityMask_,GetProcessGroupAffinity_,GetProcessHandleCount_,GetProcessId_,GetProcessIdOfThread_,GetProcessInformation_,GetProcessPriorityBoost_,GetProcessShutdownParameters_,GetProcessTimes_,GetProcessVersion_,GetProcessWorkingSetSize_,GetProcessWorkingSetSizeEx_,GetStartupInfo_,IsProcessInJob_,IsWow64Process_,NtQueryInformationProcess_,NtQueryInformationThread_,OpenJobObject_,OpenProcess_,QueryInformationJobObject_,SetEnvironmentVariable_,SetInformationJobObject_,SetPriorityClass_,SetProcessAffinityMask_,SetProcessInformation_,SetProcessShutdownParameters_,SetProcessWorkingSetSize_,SetProcessWorkingSetSizeEx_",#True)
      libs(#__LIB_PROCESS)\points + 4 * Check(line, "TerminateJobObject_,TerminateProcess_,TerminateThread_,UserHandleGrantAccess_,WaitForInputIdle_,WinExec_,ZwQueryInformationProcess", #True)
      
      libs(#__LIB_REGEXP)\points + 8 * Check(line, "CreateRegularExpression,ExtractRegularExpression,FreeRegularExpression,IsRegularExpression,MatchRegularExpression,RegularExpressionError,ReplaceRegularExpression",#True)
      libs(#__LIB_REQUESTER)\points + 8 * Check( line, "MessageBox_,ColorRequester,FontRequester,InputRequester,MessageRequester,NextSelectedFilename,OpenFileRequester,PathRequester,SaveFileRequester,SelectedFilePattern,SelectedFontColor,SelectedFontName,SelectedFontSize,SelectedFontStyle",#True)
      
      libs(#__LIB_SCINTILLA)\points + 16 * Check(line, "InitScintilla,ScintillaGadget,ScintillaSendMessage",#True)
      
      libs(#__LIB_SERIAL)\points + 16 * Check(line, "AvailableSerialPortInput,AvailableSerialPortOutput,CloseSerialPort,GetSerialPortStatus,IsSerialPort,OpenSerialPort,ReadSerialPortData,SerialPortError,SerialPortID,SerialPortTimeouts,SetSerialPortStatus,WriteSerialPortData,WriteSerialPortString",#True)
      
      libs(#__LIB_SORT)\points + 16 * Check(line, "RandomizeArray,RandomizeList,SortArray,SortList,SortStructuredArray,SortStructuredList",#True)
      
      libs(#__LIB_STATUSBAR)\points + 16 * Check(line, "AddStatusBarField,CreateStatusBar,FreeStatusBar,IsStatusBar,StatusBarHeight,StatusBarID,StatusBarImage,StatusBarProgress,StatusBarText",#True)
      
      libs(#__LIB_STRING)\points + 1 * Check(line, "Asc,Bin,Chr,CountString,FindString,Hex,InsertString,LCase,LSet,LTrim,Left,Len,Mid,RSet,RTrim,RemoveString,ReplaceString,ReverseString,Right,Space,Str,StrD,StrF,StrU,StringByteLength,StringField,Trim,UCase,Val,ValD,ValF", #True)
      
      libs(#__LIB_SYSTEM)\points + 16 * Check(line, "GetSystemMetrics_,GetVersion_,GetVersionEx_,DoubleClickTime,ElapsedMilliseconds,OSVersion,ComputerName,CountCPUs,MemoryStatus,UserName",#True)
      libs(#__LIB_SYSTEM)\points + 16 * Check(line, "#PB_OS_Windows_NT3_51,#PB_OS_Windows_95,#PB_OS_Windows_NT_4,#PB_OS_Windows_98,#PB_OS_Windows_ME,#PB_OS_Windows_2000,#PB_OS_Windows_XP,#PB_OS_Windows_Server_2003,#PB_OS_Windows_Vista,#PB_OS_Windows_Server_2008,#PB_OS_Windows_7,#PB_OS_Windows_Server_2008_R2,#PB_OS_Windows_8",#False)
      libs(#__LIB_SYSTEM)\points + 16 * Check(line, "#PB_OS_Windows_Server_2012,#PB_OS_Windows_Future,#PB_OS_Linux_2_2,#PB_OS_Linux_2_4,#PB_OS_Linux_2_6,#PB_OS_Linux_Future,#PB_OS_MacOSX_10_0,#PB_OS_MacOSX_10_1,#PB_OS_MacOSX_10_2,#PB_OS_MacOSX_10_3,#PB_OS_MacOSX_10_4,#PB_OS_MacOSX_10_5,#PB_OS_MacOSX_10_6,#PB_OS_MacOSX_10_7,#PB_OS_MacOSX_10_8,#PB_OS_MacOSX_Future",#False)
      
      libs(#__LIB_SYSTRAY)\points + 16 * Check(line, "AddSysTrayIcon,ChangeSysTrayIcon,IsSysTrayIcon,RemoveSysTrayIcon,SysTrayIconToolTip",#True)
      
      libs(#__LIB_THREAD)\points + 4 * Check(line, "CreateMutex,CreateSemaphore,CreateThread,FreeMutex,FreeSemaphore,IsThread,KillThread,LockMutex,PauseThread,ResumeThread,SignalSemaphore,ThreadID,ThreadPriority,TryLockMutex,TrySemaphore,UnlockMutex,WaitSemaphore,WaitThread",#True)
      libs(#__LIB_THREAD)\points + 4 * Check(line, "Delay",#True)
      libs(#__LIB_THREAD)\points + 4 * Check(line, "GetCurrentThread_,GetCurrentThreadId_,GetCurrentThreadStackLimits_,GetExitCodeThread_,IsThreadAFiber_,OpenThread_,ResumeThread_",#True)
      libs(#__LIB_THREAD)\points + 4 * Check(line, "ConvertFiberToThread_,ConvertThreadToFiber_,ConvertThreadToFiberEx_,CreateFiber_,CreateFiberEx_,TlsAlloc_,TlsFree_,TlsGetValue_,TlsSetValue_",#True)
      libs(#__LIB_THREAD)\points + 4 * Check(line, "DeleteFiber_,ExitThread_,GetThreadGroupAffinity_,GetThreadId_,GetThreadIdealProcessorEx_,Wow64SuspendThread_",#True)
      libs(#__LIB_THREAD)\points + 4 * Check(line, "GetThreadInformation_,GetThreadIOPendingFlag_,GetThreadPriority_,GetThreadPriorityBoost_,GetThreadTimes_",#True)
      libs(#__LIB_THREAD)\points + 4 * Check(line, "SetThreadAffinityMask_,SetThreadGroupAffinity_,SetThreadIdealProcessor_,SetThreadIdealProcessorEx_,SetThreadInformation_,SetThreadpoolThreadMaximum_,SetThreadpoolThreadMinimum_,SetThreadpoolTimer_,SetThreadpoolWait_,SetThreadPriority_,Sleep_,SleepEx_,SuspendThread_,SwitchToFiber_,SwitchToThread_",#True)
      libs(#__LIB_THREAD)\points + 4 * Check(line, "CreateRemoteThread_,CreateRemoteThreadEx_,CreateThread_,CreateThreadpool_,AttachThreadInput_CancelThreadpoolIo_,CloseThreadpool_,CloseThreadpoolIo_,CloseThreadpoolTimer_,CloseThreadpoolWait_,CloseThreadpoolWork_",#True)
      
      libs(#__LIB_TOOLBAR)\points + 8 * Check(line, "CreateToolBar,DisableToolBarButton,FreeToolBar,GetToolBarButtonState,IsToolBar,SetToolBarButtonState,ToolBarHeight,ToolBarID,ToolBarImageButton,ToolBarSeparator,ToolBarStandardButton,ToolBarToolTip",#True)
      
      libs(#__LIB_XML)\points + 16 * Check(line, "CatchXML,ChildXMLNode,CopyXMLNode,CreateXML,CreateXMLNode,DeleteXMLNode,ExamineXMLAttributes,ExportXML,ExportXMLSize,FormatXML,FreeXML,GetXMLAttribute,GetXMLEncoding,GetXMLNodeName,GetXMLNodeOffset,GetXMLNodeText,GetXMLStandalone,IsXML,LoadXML,MainXMLNode,MoveXMLNode,NextXMLAttribute,NextXMLNode,ParentXMLNode,PreviousXMLNode,RemoveXMLAttribute,ResolveXMLAttributeName,ResolveXMLNodeName,RootXMLNode,SaveXML,SetXMLAttribute,SetXMLEncoding,SetXMLNodeName,SetXMLNodeOffset,SetXMLNodeText,SetXMLStandalone,XMLAttributeName,XMLAttributeValue,XMLChildCount,XMLError,XMLErrorLine,XMLErrorPosition,XMLNodeFromID,XMLNodeFromPath,XMLNodePath,XMLNodeType,XMLStatus",#True)
      
      libs(#__LIB_JOYSTICK)\points + 16 * Check(line, "ExamineJoystick,InitJoystick,JoystickAxisX,JoystickAxisY,JoystickButton",#True)
      
      libs(#__LIB_KEYBOARD)\points + 4 * Check(line, "GetAsyncKeyState_,ExamineKeyboard,InitKeyboard,KeyboardInkey,KeyboardMode,KeyboardPushed,KeyboardReleased",#True)
      
      libs(#__LIB_MODULE)\points + 16 * Check(line, "CatchModule,FreeModule,GetModulePosition,GetModuleRow,IsModule,LoadModule,ModuleVolume,PlayModule,SetModulePosition,StopModule",#True)
      
      libs(#__LIB_MOUSE)\points + 16 * Check(line, "ExamineMouse,InitMouse,MouseButton,MouseDeltaX,MouseDeltaY,MouseLocate,MouseWheel,MouseX,MouseY,ReleaseMouse",#True)
      
      libs(#__LIB_PALETTE)\points + 16 * Check(line, "CreatePalette,DisplayPalette,FreePalette,GetPaletteColor,InitPalette,IsPalette,LoadPalette,SetPaletteColor",#True)
      
      libs(#__LIB_SPRITE3D)\points + 16 * Check( line, "CreateSprite3D,DisplaySprite3D,FreeSprite3D,InitSprite3D,IsSprite3D,RotateSprite3D,Sprite3DBlendingMode,Sprite3DQuality,Start3D,Stop3D,TransformSprite3D,ZoomSprite3D",#True)
      
      libs(#__LIB_SOUND)\points +  8 * Check(line, "CatchSound,FreeSound,GetSoundFrequency,GetSoundPosition,InitSound,IsSound,LoadSound,PauseSound,PlaySound,ResumeSound,SetSoundFrequency,SetSoundPosition,SoundLength,SoundPan,SoundStatus,SoundVolume,StopSound,UseFLACSoundDecoder,UseOGGSoundDecoder",#True)
      
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "Add3DArchive,AmbientColor,AntialiasingMode,ConvertLocalToWorldPosition,ConvertWorldToLocalPosition,CountRenderedTriangles,CreateWater,EnableWorldCollisions,EnableWorldPhysics,Engine3DFrameRate,FetchOrientation,Fog,GetW,GetX,GetY,GetZ,InitEngine3D,InputEvent3D,LoadWorld,MousePick,MouseRayCast,NormalX,NormalY,NormalZ,Parse3DScripts,PickX,PickY,PickZ,PointPick,RayCast,RayCollide,RayPick,RenderWorld,SetGUITheme3D,SetOrientation,ShowGUI,SkyBox,SkyDome,Sun,WaterColor,WorldDebug,WorldGravity,WorldShadows",#True)    
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AddBillboard,BillboardGroupID,BillboardGroupMaterial,BillboardGroupX,BillboardGroupY,BillboardGroupZ,BillboardHeight,BillboardLocate,BillboardWidth,BillboardX,BillboardY,BillboardZ,ClearBillboards,CountBillboards,CreateBillboardGroup,FreeBillboardGroup,HideBillboardGroup,IsBillboardGroup,MoveBillboard,MoveBillboardGroup,RemoveBillboard,ResizeBillboard,RotateBillboardGroup",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "CameraBackColor,CameraDirection,CameraDirectionX,CameraDirectionY,CameraDirectionZ,CameraFOV,CameraFixedYawAxis,CameraID,CameraLookAt,CameraPitch,CameraProjectionMode,CameraProjectionX,CameraProjectionY,CameraRange,CameraRenderMode,CameraRoll,CameraViewHeight,CameraViewWidth,CameraViewX,CameraViewY,CameraX,CameraY,CameraYaw,CameraZ,CreateCamera,FreeCamera,IsCamera,MoveCamera,RotateCamera,SwitchCamera",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "ApplyEntityForce,ApplyEntityImpulse,AttachEntityObject,CopyEntity,CreateEntity,DetachEntityObject,DisableEntityBody,EnableManualEntityBoneControl,EntityAngularFactor,EntityBonePitch,EntityBoneRoll,EntityBoneX,EntityBoneY,EntityBoneYaw,EntityBoneZ,EntityBoundingBox,EntityCollide,EntityCustomParameter,EntityFixedYawAxis,EntityID,EntityLinearFactor,EntityLookAt,EntityParentNode,EntityPhysicBody,EntityPitch,EntityRenderMode,EntityRoll,EntityVelocity,EntityX,EntityY,EntityYaw,EntityZ,FreeEntity,FreeEntityJoints,GetEntityAttribute,GetEntityMaterial,HideEntity,IsEntity,MoveEntity,MoveEntityBone,RotateEntity,RotateEntityBone,ScaleEntity,SetEntityAttribute,SetEntityMaterial", #True)     
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AddEntityAnimationTime,EntityAnimationBlendMode,EntityAnimationStatus,GetEntityAnimationLength,GetEntityAnimationTime,GetEntityAnimationWeight,SetEntityAnimationLength,SetEntityAnimationTime,SetEntityAnimationWeight,StartEntityAnimation,StopEntityAnimation,UpdateEntityAnimation",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "ConeTwistJoint,EnableHingeJointAngularMotor,FreeJoint,GetJointAttribute,HingeJoint,HingeJointMotorTarget,PointJoint,SetJointAttribute,SliderJoint",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "CopyLight,CreateLight,DisableLightShadows,FreeLight,GetLightColor,HideLight,IsLight,LightAttenuation,LightDirection,LightDirectionX,LightDirectionY,LightDirectionZ,LightID,LightLookAt,LightPitch,LightRoll,LightX,LightY,LightYaw,LightZ,MoveLight,RotateLight,SetLightColor,SpotLightRange",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AddMaterialLayer,CopyMaterial,CountMaterialLayers,CreateMaterial,DisableMaterialLighting,FreeMaterial,GetMaterialAttribute,GetMaterialColor,GetScriptMaterial,IsMaterial,MaterialBlendingMode,MaterialCullingMode,MaterialDepthWrite,MaterialFilteringMode,MaterialFog,MaterialID,MaterialShadingMode,MaterialShininess,ReloadMaterial,RemoveMaterialLayer,ResetMaterial,RotateMaterial,ScaleMaterial,ScrollMaterial,SetMaterialColor",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AddSubMesh,BuildMeshShadowVolume,CopyMesh,CreateCube,CreateCylinder,CreateLine3D,CreateMesh,CreatePlane,CreateSphere,FinishMesh,FreeMesh,IsMesh,LoadMesh,MeshFace,MeshID,MeshIndex,MeshRadius,MeshVertexColor,MeshVertexCount,MeshVertexNormal,MeshVertexPosition,MeshVertexTextureCoordinate,NormalizeMesh,SaveMesh,SetMeshMaterial,SubMeshCount,TransformMesh,UpdateMesh,UpdateMeshBoundingBox",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AttachNodeObject,CreateNode,DetachNodeObject,FreeNode,IsNode,MoveNode,NodeFixedYawAxis,NodeID,NodeLookAt,NodePitch,NodeRoll,NodeX,NodeY,NodeYaw,NodeZ,RotateNode,ScaleNode",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AddNodeAnimationTime,CreateNodeAnimation,CreateNodeAnimationKeyFrame,FreeNodeAnimation,GetNodeAnimationKeyFrameTime,GetNodeAnimationLength,GetNodeAnimationTime,GetNodeAnimationWeight,NodeAnimationKeyFramePitch,NodeAnimationKeyFramePosition,NodeAnimationKeyFrameRoll,NodeAnimationKeyFrameRotation,NodeAnimationKeyFrameScale,NodeAnimationKeyFrameX,NodeAnimationKeyFrameY,NodeAnimationKeyFrameYaw,NodeAnimationKeyFrameZ,NodeAnimationStatus,SetNodeAnimationLength,SetNodeAnimationTime,SetNodeAnimationWeight,StartNodeAnimation,StopNodeAnimation",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "CreateParticleEmitter,FreeParticleEmitter,GetScriptParticleEmitter,HideParticleEmitter,IsParticleEmitter,MoveParticleEmitter,ParticleColorFader,ParticleColorRange,ParticleEmissionRate,ParticleEmitterDirection,ParticleEmitterID,ParticleEmitterX,ParticleEmitterY,ParticleEmitterZ,ParticleMaterial,ParticleSize,ParticleTimeToLive,ParticleVelocity,ResizeParticleEmitter",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AttachRibbonEffect,CompositorEffectParameter,CreateCompositorEffect,CreateLensFlareEffect,CreateRibbonEffect,DetachRibbonEffect,FreeEffect,HideEffect,IsEffect,LensFlareEffectColor,RibbonEffectColor,RibbonEffectWidth",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AddSplinePoint,ClearSpline,ComputeSpline,CountSplinePoints,CreateSpline,FreeSpline,SplinePointX,SplinePointY,SplinePointZ,SplineX,SplineY,SplineZ,UpdateSplinePoint",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AddStaticGeometryEntity,BuildStaticGeometry,CreateStaticGeometry,FreeStaticGeometry,IsStaticGeometry",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AddTerrainTexture,BuildTerrain,CreateTerrain,DefineTerrainTile,FreeTerrain,GetTerrainTileHeightAtPoint,GetTerrainTileLayerBlend,SaveTerrain,SetTerrainTileHeightAtPoint,SetTerrainTileLayerBlend,SetupTerrains,TerrainHeight,TerrainLocate,TerrainMousePick,TerrainPhysicBody,TerrainRenderMode,TerrainTileHeightAtPosition,TerrainTileLayerMapSize,TerrainTilePointX,TerrainTilePointY,TerrainTileSize,UpdateTerrain,UpdateTerrainTileLayerBlend",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "CreateText3D,FreeText3D,IsText3D,MoveText3D,ScaleText3D,Text3DAlignment,Text3DCaption,Text3DColor,Text3DID",#True)
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "CreateCubeMapTexture,CreateRenderTexture,CreateTexture,EntityCubeMapTexture,FreeTexture,GetScriptTexture,IsTexture,LoadTexture,SaveRenderTexture,TextureHeight,TextureID,TextureOutput,TextureWidth,UpdateRenderTexture",#True)    
      libs(#__LIB_ENGINE3D)\points + 2 * Check(line, "AddVertexPoseReference,CreateVertexAnimation,CreateVertexPoseKeyFrame,CreateVertexTrack,MeshPoseCount,MeshPoseName,UpdateVertexPoseReference,VertexPoseReferenceCount",#True)
      
      libs(#__LIB_WINDOW3D)\points + 8 * Check(line, " CloseWindow3D,DisableWindow3D,EventGadget3D,EventType3D,EventWindow3D,GetActiveWindow3D,GetWindowTitle3D,HideWindow3D,IsWindow3D,OpenWindow3D,ResizeWindow3D,SetActiveWindow3D,SetWindowTitle3D,WindowEvent3D,WindowHeight3D,WindowID3D,WindowWidth3D,WindowX3D,WindowY3D",#True)
      libs(#__LIB_GADGET3D)\points + 8 * Check(line, "AddGadgetItem3D,ButtonGadget3D,CheckBoxGadget3D,ClearGadgetItems3D,CloseGadgetList3D,ComboBoxGadget3D,ContainerGadget3D,CountGadgetItems3D,DisableGadget3D,EditorGadget3D,Frame3DGadget3D,FreeGadget3D,GadgetHeight3D,GadgetID3D,GadgetToolTip3D,GadgetType3D,GadgetWidth3D,GadgetX3D,GadgetY3D,GetActiveGadget3D,GetGadgetAttribute3D,GetGadgetData3D,GetGadgetItemData3D,GetGadgetItemState3D,GetGadgetItemText3D,GetGadgetState3D,GetGadgetText3D,HideGadget3D,ImageGadget3D,IsGadget3D,ListViewGadget3D,OpenGadgetList3D,OptionGadget3D,PanelGadget3D,ProgressBarGadget3D,RemoveGadgetItem3D,ResizeGadget3D,ScrollAreaGadget3D,ScrollBarGadget3D,SetActiveGadget3D,SetGadgetAttribute3D,SetGadgetData3D,SetGadgetItemData3D,SetGadgetItemState3D,SetGadgetItemText3D,SetGadgetState3D,SetGadgetText3D,SpinGadget3D,StringGadget3D,TextGadget3D",#True)     
      
      libs(#__LIB_SOUND3D)\points + 8 * Check(line, "FreeSound3D,IsSound3D,LoadSound3D,PlaySound3D,SoundCone3D,SoundID3D,SoundListenerLocate,SoundRange3D,SoundVolume3D,StopSound3D",#True)
      
      libs(#__LIB_DIRECTX)\points + 128 * Check(line, "ID3DX,IDirect3D,IDirectDraw,IDirectInput,IDirectMusic,IDirectPlay,IDirectSound,IDirectXFile",#False)
      libs(#__LIB_COM)\points + 128 * Check(line, "CoCreateInstance_,CoInitialize_,CoInitializeEx_,CLSIDFromProgID_,CLSIDFromString_,CoUninitialize_,StringFromCLSID_,StringFromIID_",#True)
      libs(#__LIB_COM)\points + 128 * Check(line, "DllRegisterServer,DllUnregisterServer",#False)      
      
      libs(#__LIB_API)\points + 4 * Check(line, "_",#True)      
      
      libs(#__LIB_DLL)\points + 64 * Check(line, "AttachProcess,DetachProcess,AttachThread,DetachThread",#True)  
      libs(#__LIB_DLL)\points + 8 * Check(line, "ProcedureDLL",#False)  
      
      libs(#__LIB_MCI)\points + 32 * Check(line, "mciSendString_",#True)
      
      
      If Left(line,1) = "!"
        libs(#__LIB_ASSEMBLER)\points + 32
      EndIf  
      libs(#__LIB_ASSEMBLER)\points + 32 * Check(line, "MOV EAX,MOV EBX,MOV ECX,MOV EDX,MOV ESP,MOV ESI,MOV EDI,MOV RAX,MOV RBX,MOV RCX,MOV RDX,MOV RSP,MOV RSI,MOV RDI,POPA,PUSHA,MOVSD,MOVSX,MOVZX",#False)
      libs(#__LIB_ASSEMBLER)\points + 32 * Check(line, "ADD EAX,ADD EBX,ADD ECX,ADD EDX,ADD ESP,ADD ESI,ADD EDI,ADD RAX,ADD RBX,ADD RCX,ADD RDX,ADD RSP,ADD RSI,ADD RDI",#False)  
      libs(#__LIB_ASSEMBLER)\points + 32 * Check(line, "SUB EAX,SUB EBX,SUB ECX,SUB EDX,SUB ESP,SUB ESI,SUB EDI,SUB RAX,SUB RBX,SUB RCX,SUB RDX,SUB RSP,SUB RSI,SUB RDI",#False)     
      libs(#__LIB_ASSEMBLER)\points + 32 * Check(line, "INC EAX,INC EBX,INC ECX,INC EDX,INC ESP,INC ESI,INC EDI,INC RAX,INC RBX,INC RCX,INC RDX,INC RSP,INC RSI,INC RDI",#False)
      
      libs(#__LIB_OPENGL)\points + 16 * Check(line, "glLoadIdentity_,ChoosePixelFormat_,SetPixelFormat_,wglCreateContext_,glViewport_,wglMakeCurrent_,glPushMatrix_,glMatrixMode_,glBegin_,glColor3f_,glVertex2f_,glPopMatrix_,glEnd_,glFinish_,SwapBuffers_",#True)
      libs(#__LIB_OPENGL)\points + 32 * Check(line, "#PFD_SUPPORT_OPENGL,#PFD_DOUBLEBUFFER,opengl32.lib,glu32.lib",#False)
      
      
      
    Until Eof(#FILE_PB_CATEGORY)
    CloseFile(#FILE_PB_CATEGORY)
    
    SortStructuredArray(libs(), #PB_Sort_Descending, OffsetOf(PBLIB\points), #PB_Integer)
    
    ;Dim names.s(1)
    ;names(0) = StringField(pb_lib_list.s,libs(0)\libId, ",")
    ;names(1) = StringField(pb_lib_list.s,libs(1)\libId, ",")   
    
    ;SortArray(names(),#PB_Sort_Ascending)
    ;result.s = StringField(pb_lib_list_upper,libs(0)\libId,",") + "\" + names(0) + "\";+"+"+names(1)+"\"
    result.s = StringField(pb_lib_list.s,libs(0)\libId, ",") + "\";+"+"+names(1)+"\"    
    Debug result
  Else
    LogOut("ERROR: Failed to open file '" + file + "'!")
  EndIf
  ProcedureReturn result
EndProcedure  



Procedure.s get_png_info(sFile.s)
  *pngHead.BYTE = AllocateMemory(8192 + 1)
  If *pngHead
    If ReadFile(#FILE_PB_PAINT,sFile)
      If Lof(#FILE_PB_PAINT) > 8192
        ReadData(#FILE_PB_PAINT,*pngHead, 8192)
      Else
        ReadData(#FILE_PB_PAINT,*pngHead, Lof(#FILE_PB_PAINT))
      EndIf  
      CloseFile(#FILE_PB_PAINT)
      
      For t=0 To 8192-1
        v = PeekB(*pngHead + t)
        If v < ' ' Or v >= 127
          PokeB(*pngHead + t, ' ') ; Space
        EndIf  
      Next
      head$ = UCase(PeekS(*pngHead, -1, #PB_Ascii))
      
      If FindString(head$, UCase("Paint.NET"), 1)
        result.s = "Paint.NET"
      EndIf  
      
      If FindString(head$, UCase("Adobe ImageReady"), 1)
        result.s = "Adobe ImageReady"
      EndIf         
      If FindString(head$, UCase("Photoshop"), 1)
        result.s = "Photoshop"
      EndIf          
      If FindString(head$, UCase("Macromedia Fireworks"), 1)
        result.s = "Macromedia Fireworks"
      EndIf   
      
      If FindString(head$, UCase("Created with GIMP"), 1)
        result.s = "GIMP"
      EndIf       
      If FindString(head$, UCase("Created with The GIMP"), 1)
        result.s = "GIMP"
      EndIf           
      If FindString(head$, UCase("PhotoFiltre"), 1)
        result.s = "PhotoFiltre"
      EndIf             
      
      If FindString(head$, UCase("gnome-panel-screenshot"), 1)
        result.s = "gnome Screenshot"
      EndIf   
      If FindString(head$, UCase("Ghostscript"), 1)
        result.s = "Ghostscript"
      EndIf     
      If FindString(head$, UCase("www.inkscape.org"), 1)
        result.s = "Inkscape"
      EndIf
      If FindString(head$, UCase("XV Version"), 1)
        result.s = "XV"
      EndIf  
      If FindString(head$, UCase("MATLAB"), 1)
        result.s = "MATLAB"
      EndIf      
      
    EndIf
    FreeMemory(*pngHead)
  EndIf
  If result <> ""
    result + "\"
  EndIf  
  ProcedureReturn result
EndProcedure  



Procedure.s get_file_creation_string(sFile.s)
creation_date = GetFileDate(sFile,#PB_Date_Created )
If GetFileDate(sFile, #PB_Date_Modified ) < creation_date
creation_date = GetFileDate(sFile,#PB_Date_Modified )
EndIf

month.s = Str(Month(creation_date))
If Len(month) < 2
  month = "0" + month
EndIf  
ProcedureReturn Str(Year(creation_date))+"-" + month
EndProcedure


Procedure copy_file(file.s, MD5$)
  Protected ok = #False
  
  If JustCreateIndex = #False
    ext.s = LCase(GetExtensionPart(file))
    base.s = GetFilePart(file)
    
    If ext <> ""
      base.s = Left(base, Len(base) - (Len(ext) + 1)) ;remove point
    Else
      base.s = Left(base, Len(base) - (Len(ext))) ;remove no point    
    EndIf
    
    If ext = ""
      path.s = DestFolder + "NONE\"      
    Else
      path.s = DestFolder + UCase(ext)+"\"
    EndIf
    
    If SortByCreationDate
      path.s = path.s + get_file_creation_string(file) + "\"  
    EndIf  
    
    If AdditionalImgCategories And (ext = "png" Or ext = "jpg" Or ext = "jpeg" Or ext = "bmp" Or ext = "jp2" Or ext = "tif"  Or ext = "tiff" Or ext = "tga")
      LoadImage(1, file)
      If IsImage(1)
        
        width = ImageWidth(1)
        height = ImageHeight(1)
        If height > width
          width = ImageHeight(1)
          height = ImageWidth(1)        
        EndIf  
        
        addition.s = "thumb\"
        If width >= 280 And height >= 240
          addition = "small\"
        EndIf        
        If width >= 640 And height >= 480
          addition = "medium\"
        EndIf  
        If width >= 1600 And height >= 1000
          addition = "big\"
        EndIf         
        If width = height
          
          addition = "square\"          
          
          If width >= 100
            addition = "square\small\"
          EndIf
          If width >= 300
            addition = "square\medium\"
          EndIf           
          If width >= 800
            addition = "square\big\"
          EndIf
          
          If ext = "png" 
            If width = 16 And height = 16
              addition = "square\16x16\"
            EndIf  
            If width = 24 And height = 24
              addition = "square\24x24\"
            EndIf 
            If width = 32 And height = 32
              addition = "square\32x32\"
            EndIf 
            If width = 48 And height = 48
              addition = "square\48x48\"
            EndIf  
            If width = 64 And height = 64
              addition = "square\64x64\"
            EndIf                    
            If width = 96 And height = 96
              addition = "square\96x96\"
            EndIf
            If width = 128 And height = 128
              addition = "square\128x128\"
            EndIf        
            If width = 256 And height = 256
              addition = "square\256x256\"
            EndIf 
            If width = 512 And height = 512
              addition = "square\512x512\"
            EndIf 
            If width = 1024 And height = 1024
              addition = "square\1024x1024\"
            EndIf 
            If width = 2048 And height = 2048
              addition = "square\2048x2048\"
            EndIf             
          EndIf       
        EndIf 
        
        bWallpaper = 0
        
        If width = 1024 And height = 768:bWallpaper =1:EndIf
        If width = 640 And height = 480:bWallpaper =1:EndIf
        If width = 800 And height = 600:bWallpaper =1:EndIf         
        If width = 1920 And height = 1080:bWallpaper =1:EndIf    
        If width = 1768 And height = 992:bWallpaper =1:EndIf 
        If width = 1152 And height = 864:bWallpaper =1:EndIf 
        If width = 1176 And height = 664:bWallpaper =1:EndIf  
        If width = 1280 And height = 720:bWallpaper =1:EndIf  
        If width = 1280 And height = 768:bWallpaper =1:EndIf  
        If width = 1280 And height = 800:bWallpaper =1:EndIf 
        If width = 1280 And height = 960:bWallpaper =1:EndIf 
        If width = 1280 And height = 1024:bWallpaper =1:EndIf 
        If width = 1360 And height = 768:bWallpaper =1:EndIf  
        If width = 1600 And height = 900:bWallpaper =1:EndIf  
        If width = 1600 And height = 1024:bWallpaper =1:EndIf 
        If width = 1680 And height = 1050:bWallpaper =1:EndIf  
             
        If bWallpaper 
          addition = "wallpaper screenshot\"     
        EndIf          
        
        path = path + addition
        
        If ext = "png"
          path = path + get_png_info(file)       
        EndIf  
        
        FreeImage(1)
      EndIf  
    EndIf  
    
    If AdditionalImgCategories And (ext = "pb" Or ext = "pbi")
      path = path + get_pb_file_category(file.s)
    EndIf
    
    If KeepPath     
      path + Fit(Right(GetPathPart(file), Len(GetPathPart(file)) - Len(SrcFolder.s)))    
    EndIf  
    
    If ext <> ""
      dst_file.s = path + base + "." + ext
    Else
      dst_file.s = path + base  
    EndIf  
    
    
    If FileSize(dst_file) >= 0
      base = base + " " + MD5$
      If ext <> ""
        dst_file.s = path + base + "." + ext
      Else
        dst_file.s = path + base  
      EndIf      
    EndIf  
    
    If FileSize(dst_file) >= 0
      LogOut("ERROR: Cannot find an non existing filename for source: '" + file + "'")  
    Else
      SHCreateDirectory_(#Null, path)
      If CopyFile(file, dst_file) = #False
        LogOut("ERROR: Cannot copy file from: '" + file + "' to '" +  dst_file +"' !") 
      Else 
        ok = #True
      EndIf  
    EndIf    
    
  Else
    ok = #True
  EndIf
  ProcedureReturn ok  
EndProcedure  

Procedure add_files(dir.s)
  If Len(dir.s) < #MAX_PATH
    id = ExamineDirectory(#PB_Any, dir, "*.*")
    If id <> 0
      While NextDirectoryEntry(id)
        FileName$ = DirectoryEntryName(id)
        If DirectoryEntryType(id) = #PB_DirectoryEntry_Directory
          If DirectoryEntryName(id) <> "." And DirectoryEntryName(id) <> ".."
            add_files(Fit(dir) + DirectoryEntryName(id)) 
          EndIf  
        EndIf    
        If DirectoryEntryType(id) = #PB_DirectoryEntry_File
          
          file.s = Fit(dir.s)+ DirectoryEntryName(id)          
          sz.q = FileSize(file.s)          
          StatusBarText(0, 0, file.s)
          SimpleMessageProcess()
          
          If IsAllowedExtension(GetExtensionPart(file.s))
            If sz >= MinSize And sz <= MaxSize
              MD5$= MD5OfFile(file.s)
              If MD5$ <> ""              
                If index_contains_MD5(MD5$)
                  LogOut("OK: folder already contains " + file + "  ( MD5: " + MD5$ +" )")
                Else
                  If copy_file(file.s, MD5$)
                    LogOut("OK: adding " + file + "  ( MD5: " + MD5$ +" )")  
                    index_add_MD5(MD5$)
                  EndIf  
                EndIf             
              EndIf
            ElseIf sz < 0
              LogOut("ERROR: entry is not a file '" + file +"'")
            Else
              LogOut("INFO: ignoring file '" + file + "' ( size: " + Str(sz) + " bytes )")
            EndIf  
          Else
            LogOut("INFO: ignoring file '" + file + "' ( extension: '" + GetExtensionPart(file.s) + "' )")            
          EndIf
          
        EndIf  
      Wend
      FinishDirectory(id)
    Else
      LogOut("ERROR: failed to list directory: '" + dir.s + "'")
    EndIf
  Else
    LogOut("WARN: path '" + dir.s + "' is IGNORED because it is too long.")  
  EndIf
EndProcedure



OpenWindow(0, 0, 0, #WINDOW_WIDTH, #WINDOW_HEIGHT, "FileSorter", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget)

SelectFileGadget(#GADGET_STRING_SOURCE,5,5,#WINDOW_WIDTH - 10,"Select a source folder. The content will be added to the destination folder.", "")

SelectFileGadget(#GADGET_STRING_DESTINATION, 5,55,#WINDOW_WIDTH - 10,"Select destination folder for files sorted by ending.", "")

TextGadget(#PB_Any, 5,100, #WINDOW_WIDTH-10,20, "Allowed Extensions (If empty then all extensions are allowed. Use NONE for files with no extension):")
StringGadget(#GADGET_STRING_ALLOWED_EXTENSIONS,5, 120, #WINDOW_WIDTH-10,21, "JPG,JPEG,BMP,PNG,PDF,PB,PBI")

TextGadget(#PB_Any, 5,150, #WINDOW_WIDTH-10,20, "Minimum and Maximum size:")
ComboBoxGadget(#GADGET_COMBO_MIN, 5, 170, 100, 21)
ComboBoxGadget(#GADGET_COMBO_MAX, 120, 170, 100, 21)

FillWithSizes(#GADGET_COMBO_MIN)
FillWithSizes(#GADGET_COMBO_MAX)

CheckBoxGadget(#GADGET_CHECKBOX_ADDITIONAL_IMAGE_CATEGORIES, 5, 200, 400, 21, "Use additional subfolders for known file endings")
CheckBoxGadget(#GADGET_CHECKBOX_JUST_INDEX, 410,200,200, 21, "Just create index")

CheckBoxGadget(#GADGET_CHECKBOX_SORTBYDATE, 410,225,200, 21, "Sort by date")
CheckBoxGadget(#GADGET_CHECKBOX_KEEP_PATH, 410,250,200, 21, "Keep path")

SetGadgetState(#GADGET_CHECKBOX_ADDITIONAL_IMAGE_CATEGORIES, #True)

ButtonGadget(#GADGET_BUTTON_START, 5, 240, 100,21, "Start")

ListIconGadget(#GADGET_LOG, 5, 300, #WINDOW_WIDTH-10, 350, "Log", 6000, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
ButtonGadget(#GADGET_BUTTON_SAVE_TO_FILE, 5, 655, 100,21, "Save Log")
ButtonGadget(#GADGET_BUTTON_CLEAR_LOG, 120, 655, 100,21, "Clear Log")



If CreateStatusBar(0, WindowID(0))
  AddStatusBarField(#WINDOW_WIDTH-50)
  AddStatusBarField(50)
EndIf

Repeat
  
  event = WaitWindowEvent()
  ProcessDialog(event)
  
  If event = #PB_Event_Gadget
    
    
    If EventGadget() = #GADGET_BUTTON_CLEAR_LOG
      ClearGadgetItems(#GADGET_LOG)
    EndIf  
    
    If EventGadget() = #GADGET_BUTTON_SAVE_TO_FILE
      Pattern$ = "Text (*.txt)|*.txt|All files (*.*)|*.*"
      Pattern = 0 
      File$ = SaveFileRequester("Please choose file to save", "log.txt", Pattern$, Pattern)
      If File$
        If CreateFile(#FILE_LOG, File$) And FileSize(File$) <= 0
          For i = 0 To CountGadgetItems(#GADGET_LOG)-1
            WriteStringN(#FILE_LOG, GetGadgetItemText(#GADGET_LOG,i), #PB_UTF8) 
          Next  
          CloseFile(#FILE_LOG)
        Else
          MessageRequester("Error","Cannot create or overwrite file '"+File$+"'")
        EndIf
      EndIf      
    EndIf  
    
    If EventGadget() = #GADGET_BUTTON_START
      DisableGadget(#GADGET_BUTTON_START, #True)
      
      If GetGadgetText(#GADGET_STRING_SOURCE) <> "" 
        If GetGadgetText(#GADGET_STRING_DESTINATION) <> "" 
          ClearGadgetItems(#GADGET_LOG)
          UpdateParameters()
          add_files(SrcFolder)
          StatusBarProgress(0, 1, 0,#PB_StatusBar_Raised ,0,100)          
          LogOut("Done")          
        Else
          MessageRequester("Error","Please select a destinaition folder!")
        EndIf
      Else
        MessageRequester("Error","Please select a source folder!")
      EndIf
      
      DisableGadget(#GADGET_BUTTON_START, #False)
    EndIf
    
    
  EndIf
  
Until event = #PB_Event_CloseWindow

EndApp()

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 912
; FirstLine = 401
; Folding = ----
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; UseIcon = icon.ico