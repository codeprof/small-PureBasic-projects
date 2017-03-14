; *************************************************************************************
; *   P r o j e c t :   N A G E N T
; *************************************************************************************
; *
; *   Version:     Date :            Description:
; *
; *   0.01         27.12.2006        Added nAgent_Init()
; *                                  Added nAgent_GetName()
; *                                  Added nAgent_MoveTo()
; *                                  Added nAgent_Think()
; *                                  Added nAgent_PointAt(
; *                                  Added nAgent_Stop()
; *                                  Added nAgent_StopAll()
; *                                  Added nAgent_Hide()
; *                                  Added nAgent_Show()
; *                                  Added nAgent_PlayAction()
; *                                  Added nAgent_Speak()
; *                                  Added nAgent_SetPos()
; *                                  Added nAgent_GetPosX()
; *                                  Added nAgent_GetPosY()
; *                                  Added nAgent_GetNumActions()
; *                                  Added nAgent_GetAction()
; *                                  Added nAgent_Free()
; *
 
#HEAP_ZERO_MEMORY=8
 
#CLSCTX_INPROC_SERVER = $1
#CLSCTX_INPROC_HANDLER = $2
#CLSCTX_LOCAL_SERVER = $4
#CLSCTX_INPROC_SERVER16 = $8
#CLSCTX_REMOTE_SERVER = $10
#CLSCTX_INPROC_HANDLER16 = $20
#CLSCTX_INPROC_SERVERX86 = $40
#CLSCTX_INPROC_HANDLERX86 = $80
#CLSCTX_ESERVER_HANDLER = $100
#CLSCTX_RESERVED = $200
#CLSCTX_NO_CODE_DOWNLOAD = $400
#CLSCTX_NO_WX86_TRANSLATION = $800
#CLSCTX_NO_CUSTOM_MARSHAL = $1000
#CLSCTX_ENABLE_CODE_DOWNLOAD = $2000
#CLSCTX_NO_FAILURE_LOG = $4000
 
#CLSCTX_SERVER=#CLSCTX_INPROC_SERVER|#CLSCTX_LOCAL_SERVER|#CLSCTX_REMOTE_SERVER
 
Interface IAgentEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Load(a.l,b.l,c.l,d.l,e.f,f.f) ; variant
  Unload(a.l)
  Register(a.l, b.l)
  Unregister(a.l)
  GetCharacter(a.l, b.l)
  GetSuspended(a.l)
  GetCharacterEx(a.l, b.l)
  GetVersion(a.l, b.l)
  ShowDefaultCharacterProperties(a.l, b.l, c.l)
EndInterface
 
 
Interface IAgentCharacterEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  GetVisible(a.l)
  SetPosition(a.l, b.l)
  GetPosition(a.l, b.l)
  SetSize(a.l, b.l)
  GetSize(a.l, b.l)
  GetName(a.l)
  GetDescription(a.l)
  GetTTSSpeed(a.l)
  GetTTSPitch(a.l)
  Activate(a.l)
  SetIdleOn(a.l)
  GetIdleOn(a.l)
  Prepare(a.l, b.p-bstr, c.l, d.l)
  Play(a.p-bstr, b.l)
  Stop(a.l)
  StopAll(a.l)
  Wait(a.l, b.l)
  Interrupt(a.l, b.l)
  Show(a.l, b.l)
  Hide(a.l, b.l)
  Speak(a.p-bstr, b.p-bstr, c.l)
  MoveTo(a.l, b.l, c.l, d.l)
  GestureAt(a.l, b.l, c.l)
  GetMoveCause(a.l)
  GetVisibilityCause(a.l)
  HasOtherClients(a.l)
  SetSoundEffectsOn(a.l)
  GetSoundEffectsOn(a.l)
  SetName(a.p-bstr)
  SetDescription(a.p-bstr)
  GetExtraData(a.l)
  ShowPopupMenu(a.l, b.l)
  SetAutoPopupMenu(a.l)
  GetAutoPopupMenu(a.l)
  GetHelpFileName(a.l)
  SetHelpFileName(a.p-bstr)
  SetHelpModeOn(a.l)
  GetHelpModeOn(a.l)
  SetHelpContextID(a.l)
  GetHelpContextID(a.l)
  GetActive(a.l)
  Listen(a.l)
  SetLanguageID(a.l)
  GetLanguageID(a.l)
  GetTTSModeID(a.l)
  SetTTSModeID(a.p-bstr)
  GetSRModeID(a.l)
  SetSRModeID(a.p-bstr)
  GetGUID(a.l)
  GetOriginalSize(a.l, b.l)
  Think(a.p-bstr, b.l)
  GetVersion(a.l, b.l)
  GetAnimationNames(a.l)
  GetSRStatus(a.l)
EndInterface
 
 
Structure _g_nAgent
  *AgentEx.IAgentEx
  *CharEx.IAgentCharacterEx
  lCharID.l
  lRequestID.l
EndStructure
 
Global g_nAgent._g_nAgent
 
 
; *************************************************************************************
; *
; *  Function:       nAgent_Init (sFile.s)
; *
; *  Description:    Initializes an Agent. You can use "" for sFile to load the the
; *                  Default character.
; *
; *  Parameters:     sFile.s = File name of a .acs - file
; *
; *  Return:         If the function succeeds, the return value is nonzero.
; *                  If the function fails, the return value is FALSE.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_Init(sFile.s)
  Protected v.variant,lResult.l,*AgentEx.IAgentEx,*CharEx.IAgentCharacterEx,p.l,s.l,sCurrentDir.s
  Protected lCharID.l,lRequestID.l
  If g_nAgent\AgentEx:ProcedureReturn #False:EndIf
  lResult=CoInitialize_(0)
 
  If lResult=#S_OK Or lResult=#S_FALSE
   
    If CoCreateInstance_(?CLSID_AgentServer,0,#CLSCTX_SERVER,?IID_IAgentEx,@*AgentEx)<>#S_OK
      CoUninitialize_()
      ProcedureReturn #False
    EndIf
   
    If sFile=""
      ;try to load the default charakter if sFile is ""
     
      ;*AgentEx\Load(0,0,0,0,@CharID,@RequestID) ; should work too, but doesn't...
      CallFunctionFast(PeekL(PeekL(*AgentEx)+OffsetOf(IAgentEx\Load())),*AgentEx,0,0,0,0,@lCharID,@lRequestID)
    Else
     
      *sFile=HeapAlloc_(GetProcessHeap_(),#HEAP_ZERO_MEMORY,#MAX_PATH*2)
      If *sFile
        PokeS(*sFile,sFile,-1,#PB_Unicode)
       
        v\vt=#VT_BSTR
        v\bstrVal=SysAllocString_(*sFile)
        CallFunctionFast(PeekL(PeekL(*AgentEx)+OffsetOf(IAgentEx\Load())),*AgentEx,v\vt,0,v\bstrVal,0,@lCharID,@lRequestID)
        SysFreeString_(v\bstrVal)
       
        If CharID=0 ; maybe it's a relative path...
          sCurrentDir=Space(#MAX_PATH)
          GetCurrentDirectory_(#MAX_PATH,sCurrentDir)
          PokeS(*sFile,sCurrentDir+"\"+sFile,-1,#PB_Unicode)
         
          v\vt=#VT_BSTR
          v\bstrVal=SysAllocString_(*sFile)
         
          CallFunctionFast(PeekL(PeekL(*AgentEx)+OffsetOf(IAgentEx\Load())),*AgentEx,v\vt,0,v\bstrVal,0,@lCharID,@lRequestID)
          SysFreeString_(v\bstrVal)
         
        EndIf
        HeapFree_(GetProcessHeap_(),0,*sFile)
      EndIf
     
    EndIf
   
   
    If lCharID=0
      *AgentEx\Release()
      CoUninitialize_()
      ProcedureReturn #False
    EndIf
   
   
    *AgentEx\GetCharacterEx(lCharID,@*CharEx)
   
    If *CharEx=0
      *AgentEx\UnLoad(lCharID)
      *AgentEx\Release()
      CoUninitialize_()
      ProcedureReturn #False
    EndIf
   
    p=#LANG_ENGLISH
    s=#SUBLANG_ENGLISH_US
    *CharEx\SetLanguageID(((s)<<10)|(p)) ; set language to english, so that we can hear something...
    *CharEx\Show(0,@g_nAgent\lRequestID)
   
    g_nAgent\AgentEx=*AgentEx
    g_nAgent\CharEx=*CharEx
    g_nAgent\lCharID=lCharID
   
    ProcedureReturn g_nAgent
  EndIf
 
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_GetName ()
; *
; *  Description:    Retuns the name of the loaded charakter
; *
; *  Parameters:     n/a
; *
; *  Return:         If the function succeeds, it returns the name of the character.
; *                  If the function fails, it returns "".
; *
; *************************************************************************************
 
ProcedureDLL.s nAgent_GetName()
  Protected sResult.s,bstrName.l
  If g_nAgent\CharEx=0:ProcedureReturn "":EndIf
  g_nAgent\CharEx\GetName(@bstrName)
  If bstrName
    sResult=PeekS(bstrName,-1,#PB_Unicode)
  EndIf
  ; SysFreeString_(bstrName) ; shoud we free the string ?
  ProcedureReturn sResult
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_MoveTo (x.l,y.l,lTime.l)
; *
; *  Description:    Moves the character to the decalred position on screen in the
; *                  declared time in ms
; *
; *  Parameters:     x.l = x position in pixel
; *                  y.l = y position in pixel
; *                  lTime.l = duration in ms
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_MoveTo(x.l,y.l,lTime.l)
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\MoveTo(x.l,y.l,lTime,@g_nAgent\lRequestID)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_Think (sText.s)
; *
; *  Description:    Shows the declared text in a balloon
; *
; *  Parameters:     sText.s = text to show
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_Think(sText.s)
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\Think(sText,@g_nAgent\lRequestID)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_PointAt (x.l, y.l)
; *
; *  Description:    Lets the character point at the declared position
; *
; *  Parameters:     x.l = x position in pixel
; *                  y.l = y position in pixel
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_PointAt(x.l,y.l)
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\GestureAt(x,y,@g_nAgent\lRequestID)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_Stop ()
; *
; *  Description:    Stops the last action of the character
; *
; *  Parameters:     n/a
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_Stop()
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\Stop(g_nAgent\lRequestID)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_StopAll ()
; *
; *  Description:    Stops all actions of the character
; *
; *  Parameters:     n/a
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_StopAll()
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\StopAll(0)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_Hide ()
; *
; *  Description:    Hides the character
; *
; *  Parameters:     n/a
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_Hide()
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\Hide(0,@g_nAgent\lRequestID)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_Show ()
; *
; *  Description:    Shows the character
; *
; *  Parameters:     n/a
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_Show()
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\Show(0,@g_nAgent\lRequestID)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_PlayAction (sAction.s)
; *
; *  Description:    Plays the declared action
; *
; *  Parameters:     sAction.s = action
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_PlayAction(sAction.s)
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\Play(sAction,@g_nAgent\lRequestID)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_Speak (sText.s)
; *
; *  Description:    Speaks the declared text
; *
; *  Parameters:     sText.s = Text to speak
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_Speak(sText.s)
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\Speak(sText,"",@g_nAgent\lRequestID)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_SetPos (x.l,y.l)
; *
; *  Description:    Set the position of the character
; *
; *  Parameters:     x.l = x position  
; *                  y.l = y position  
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_SetPos(x.l,y.l)
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\SetPosition(x,y)=#S_OK
    ProcedureReturn #True
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_GetPosX ()
; *
; *  Description:    Get the x position of the character
; *
; *  Parameters:     n/a
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_GetPosX()
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\GetPosition(@x,@y)=#S_OK
    ProcedureReturn x
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_GetPosY ()
; *
; *  Description:    Get the y position of the character
; *
; *  Parameters:     n/a
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_GetPosY()
  If g_nAgent\CharEx=0:ProcedureReturn #False:EndIf
  If g_nAgent\CharEx\GetPosition(@x,@y)=#S_OK
    ProcedureReturn y
  EndIf
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_GetNumActions ()
; *
; *  Description:    Returns the number of actions
; *
; *  Parameters:     n/a
; *
; *  Return:         If the function succeeds, it returns the number of actions.
; *                  If the function fails, it returns 0.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_GetNumActions()
  Protected *AnimNames.IUnknown,*Enum.IEnumVARIANT,lExit.l,lResult.l,lcount.l
  If g_nAgent\CharEx=0:ProcedureReturn 0:EndIf
 
  g_nAgent\CharEx\GetAnimationNames(@*AnimNames)
  If *AnimNames=0:ProcedureReturn 0:EndIf
 
  *AnimNames\QueryInterface(?IID_IEnumVARIANT,@*Enum)
  If *Enum=0
    *AnimNames\Release()
    ProcedureReturn 0
  EndIf
 
  While lExit=#False
  If *Enum\Next(1,vAnimName.VARIANT,@lResult)=#S_OK
    VariantClear_(vAnimName)
  Else
    lExit=#True
  EndIf
  lcount+1
Wend
*Enum\Release()
*AnimNames\Release()
ProcedureReturn lcount-1
EndProcedure
 
; *************************************************************************************
; *
; *  Function:       nAgent_GetAction (lIndex.l)
; *
; *  Description:    Returns an action
; *
; *  Parameters:     lIndex.l = index
; *
; *  Return:         If the function succeeds, it returns the name of the action.
; *                  If the function fails, it returns "".
; *
; *************************************************************************************
 
ProcedureDLL.s nAgent_GetAction(lIndex.l)
  Protected *AnimNames.IUnknown,*Enum.IEnumVARIANT,lExit.l,lResult.l,lcount.l,sResult.s
  If g_nAgent\CharEx=0:ProcedureReturn "":EndIf
 
  g_nAgent\CharEx\GetAnimationNames(@*AnimNames)
  If *AnimNames=0:ProcedureReturn "":EndIf
 
  *AnimNames\QueryInterface(?IID_IEnumVARIANT,@*Enum)
  If *Enum=0
    *AnimNames\Release()
    ProcedureReturn ""
  EndIf
 
  While lExit=#False
  If *Enum\Next(1,vAnimName.VARIANT,@lResult)=#S_OK
   
    If lcount=lIndex
      sResult.s=PeekS(vAnimName\bstrVal,-1,#PB_Unicode)
    EndIf
    VariantClear_(vAnimName)
  Else
    lExit=#True
  EndIf
  lcount+1
Wend
*Enum\Release()
*AnimNames\Release()
ProcedureReturn sResult
EndProcedure
 
 
; *************************************************************************************
; *
; *  Function:       nAgent_Free ()
; *
; *  Description:    Closes the agent opened with nAgent_Init()
; *
; *  Parameters:     n/a
; *
; *  Return:         If the function succeeds, it returns true.
; *                  If the function fails, it returns false.
; *
; *************************************************************************************
 
ProcedureDLL.l nAgent_Free()
  If g_nAgent\AgentEx=0:ProcedureReturn #False:EndIf
  g_nAgent\AgentEx\Unload(g_nAgent\lCharID)
  g_nAgent\CharEx\Release()
  g_nAgent\AgentEx\Release()
  g_nAgent\CharEx=0
  g_nAgent\AgentEx=0
  g_nAgent\lCharID=0
  g_nAgent\lRequestID=0
  CoUninitialize_()
  ProcedureReturn #True
EndProcedure
 
 
DataSection
IID_IAgentEx:
Data.l $48D12BA0
Data.w $5B77,$11D1
Data.b $9E,$C1,$0,$C0,$4F,$D7,$08,$1F
 
CLSID_AgentServer:
Data.l $D45FD2FC
Data.w $5C6E,$11D1
Data.b $9E,$C1,$0,$C0,$4F,$D7,$08,$1F
 
IID_IEnumVARIANT:
Data.l $00020404
Data.w 0,0
Data.b $C0,00,00,00,00,00,00,$46
EndDataSection
