
Enumeration ; CONST_DSBCAPSFLAGS
  #DSBCAPS_PRIMARYBUFFER=1
  #DSBCAPS_STATIC=2
  #DSBCAPS_LOCHARDWARE=4
  #DSBCAPS_LOCSOFTWARE=8
  #DSBCAPS_CTRL3D=16
  #DSBCAPS_CTRLFREQUENCY=32
  #DSBCAPS_CTRLPAN=64
  #DSBCAPS_CTRLVOLUME=128
  #DSBCAPS_CTRLPOSITIONNOTIFY=256
  #DSBCAPS_CTRLFX=512
  #DSBCAPS_CTRLCHANNELVOLUME=1024
  #DSBCAPS_STICKYFOCUS=16384
  #DSBCAPS_GLOBALFOCUS=32768
  #DSBCAPS_GETCURRENTPOSITION2=65536
  #DSBCAPS_MUTE3DATMAXDISTANCE=131072
  #DSBCAPS_LOCDEFER=262144
EndEnumeration

Enumeration ; CONST_DS3DMODEFLAGS
  #DS3DMODE_NORMAL=0
  #DS3DMODE_HEADRELATIVE=1
  #DS3DMODE_DISABLE=2
EndEnumeration

Enumeration ; CONST_DS3DAPPLYFLAGS
  #DS3D_IMMEDIATE=0
  #DS3D_DEFERRED=1
EndEnumeration

Enumeration ; CONST_DSBSTATUSFLAGS
  #DSBSTATUS_PLAYING=1
  #DSBSTATUS_BUFFERLOST=2
  #DSBSTATUS_LOOPING=4
  #DSBSTATUS_LOCHARDWARE=8
  #DSBSTATUS_LOCSOFTWARE=16
  #DSBSTATUS_TERMINATED=32
EndEnumeration

Enumeration ; CONST_DSBLOCKFLAGS
  #DSBLOCK_DEFAULT=0
  #DSBLOCK_FROMWRITECURSOR=1
  #DSBLOCK_ENTIREBUFFER=2
EndEnumeration

Enumeration ; CONST_DSBPLAYFLAGS
  #DSBPLAY_DEFAULT=0
  #DSBPLAY_LOOPING=1
  #DSBPLAY_LOCHARDWARE=2
  #DSBPLAY_LOCSOFTWARE=4
  #DSBPLAY_TERMINATEBY_TIME=8
  #DSBPLAY_TERMINATEBY_DISTANCE=16
  #DSBPLAY_TERMINATEBY_PRIORITY=32
EndEnumeration

Enumeration ; CONST_DSCAPSFLAGS
  #DSCAPS_PRIMARYMONO=1
  #DSCAPS_PRIMARYSTEREO=2
  #DSCAPS_PRIMARY8BIT=4
  #DSCAPS_PRIMARY16BIT=8
  #DSCAPS_CONTINUOUSRATE=16
  #DSCAPS_EMULDRIVER=32
  #DSCAPS_CERTIFIED=64
  #DSCAPS_SECONDARYMONO=256
  #DSCAPS_SECONDARYSTEREO=512
  #DSCAPS_SECONDARY8BIT=1024
  #DSCAPS_SECONDARY16BIT=2048
EndEnumeration

Enumeration ; CONST_DSSCLFLAGS
  #DSSCL_NORMAL=1
  #DSSCL_PRIORITY=2
  #DSSCL_WRITEPRIMARY=4
EndEnumeration

Enumeration ; CONST_DSSPEAKERFLAGS
  #DSSPEAKER_HEADPHONE=1
  #DSSPEAKER_MONO=2
  #DSSPEAKER_QUAD=3
  #DSSPEAKER_STEREO=4
  #DSSPEAKER_SURROUND=5
  #DSSPEAKER_GEOMETRY_MIN=5
  #DSSPEAKER_GEOMETRY_NARROW=10
  #DSSPEAKER_GEOMETRY_WIDE=20
  #DSSPEAKER_GEOMETRY_MAX=180
EndEnumeration

Enumeration ; CONST_DSCBCAPSFLAGS
  #DSCBCAPS_DEFAULT=0
  #DSCBCAPS_WAVEMAPPED=-2147483648
EndEnumeration

Enumeration ; CONST_DSCBSTATUSFLAGS
  #DSCBSTATUS_CAPTURING=1
  #DSCBSTATUS_LOOPING=2
EndEnumeration

Enumeration ; CONST_DSCBSTARTFLAGS
  #DSCBSTART_DEFAULT=0
  #DSCBSTART_LOOPING=1
EndEnumeration

Enumeration ; CONST_DSCBLOCKFLAGS
  #DSCBLOCK_DEFAULT=0
  #DSCBLOCK_ENTIREBUFFER=1
EndEnumeration

Enumeration ; CONST_DSCCAPSFLAGS
  #DSCCAPS_DEFAULT=0
  #DSCCAPS_EMULDRIVER=32
EndEnumeration

Enumeration ; CONST_WAVEFORMATFLAGS
  #WAVE_FORMAT_1M08=1
  #WAVE_FORMAT_1S08=2
  #WAVE_FORMAT_1M16=4
  #WAVE_FORMAT_1S16=8
  #WAVE_FORMAT_2M08=16
  #WAVE_FORMAT_2S08=32
  #WAVE_FORMAT_2M16=64
  #WAVE_FORMAT_2S16=128
  #WAVE_FORMAT_4M08=256
  #WAVE_FORMAT_4S08=512
  #WAVE_FORMAT_4M16=1024
  #WAVE_FORMAT_4S16=2048
EndEnumeration

Enumeration ; CONST_DSFXGARGLE_RATEHZ
  #DSFXGARGLE_RATEHZ_MIN=1
  #DSFXGARGLE_RATEHZ_MAX=1000
EndEnumeration

Enumeration ; CONST_DSFXGARGLE_WAVE
  #DSFXGARGLE_WAVE_TRIANGLE=0
  #DSFXGARGLE_WAVE_SQUARE=1
EndEnumeration

Enumeration ; CONST_DSFX_WAVE
  #DSFX_WAVE_TRIANGLE=0
  #DSFX_WAVE_SIN=1
EndEnumeration

Enumeration ; CONST_DSFX_PHASE
  #DSFX_PHASE_MIN=0
  #DSFX_PHASE_MAX=4
  #DSFX_PHASE_NEG_180=0
  #DSFX_PHASE_NEG_90=1
  #DSFX_PHASE_ZERO=2
  #DSFX_PHASE_90=3
  #DSFX_PHASE_180=4
EndEnumeration

Enumeration ; CONST_DSFX_PANDELAY
  #DSFX_PANDELAY_MIN=0
  #DSFX_PANDELAY_MAX=1
EndEnumeration

Enumeration ; CONST_DSFX_I3DL2_ENVIRONMENT_PRESETS
  #DSFX_I3DL2_ENVIRONMENT_PRESET_DEFAULT=0
  #DSFX_I3DL2_ENVIRONMENT_PRESET_GENERIC=1
  #DSFX_I3DL2_ENVIRONMENT_PRESET_PADDEDCELL=2
  #DSFX_I3DL2_ENVIRONMENT_PRESET_ROOM=3
  #DSFX_I3DL2_ENVIRONMENT_PRESET_BATHROOM=4
  #DSFX_I3DL2_ENVIRONMENT_PRESET_LIVINGROOM=5
  #DSFX_I3DL2_ENVIRONMENT_PRESET_STONEROOM=6
  #DSFX_I3DL2_ENVIRONMENT_PRESET_AUDITORIUM=7
  #DSFX_I3DL2_ENVIRONMENT_PRESET_CONCERTHALL=8
  #DSFX_I3DL2_ENVIRONMENT_PRESET_CAVE=9
  #DSFX_I3DL2_ENVIRONMENT_PRESET_ARENA=10
  #DSFX_I3DL2_ENVIRONMENT_PRESET_HANGAR=11
  #DSFX_I3DL2_ENVIRONMENT_PRESET_CARPETEDHALLWAY=12
  #DSFX_I3DL2_ENVIRONMENT_PRESET_HALLWAY=13
  #DSFX_I3DL2_ENVIRONMENT_PRESET_STONECORRIDOR=14
  #DSFX_I3DL2_ENVIRONMENT_PRESET_ALLEY=15
  #DSFX_I3DL2_ENVIRONMENT_PRESET_FOREST=16
  #DSFX_I3DL2_ENVIRONMENT_PRESET_CITY=17
  #DSFX_I3DL2_ENVIRONMENT_PRESET_MOUNTAINS=18
  #DSFX_I3DL2_ENVIRONMENT_PRESET_QUARRY=19
  #DSFX_I3DL2_ENVIRONMENT_PRESET_PLAIN=20
  #DSFX_I3DL2_ENVIRONMENT_PRESET_PARKINGLOT=21
  #DSFX_I3DL2_ENVIRONMENT_PRESET_SEWERPIPE=22
  #DSFX_I3DL2_ENVIRONMENT_PRESET_UNDERWATER=23
  #DSFX_I3DL2_ENVIRONMENT_PRESET_SMALLROOM=24
  #DSFX_I3DL2_ENVIRONMENT_PRESET_MEDIUMROOM=25
  #DSFX_I3DL2_ENVIRONMENT_PRESET_LARGEROOM=26
  #DSFX_I3DL2_ENVIRONMENT_PRESET_MEDIUMHALL=27
  #DSFX_I3DL2_ENVIRONMENT_PRESET_LARGEHALL=28
  #DSFX_I3DL2_ENVIRONMENT_PRESET_PLATE=29
EndEnumeration

Enumeration ; CONST_DSFX_I3DL2REVERB_QUALITY
  #DSFX_I3DL2REVERB_QUALITY_MIN=0
  #DSFX_I3DL2REVERB_QUALITY_MAX=3
  #DSFX_I3DL2REVERB_QUALITY_DEFAULT=2
EndEnumeration

Structure DSBUFFERDESC 
  dwSize.l 
  dwFlags.l 
  dwBufferBytes.l 
  dwReserved.l 
  lpwfxFormat.l ; pointer to WAVEFORMATEX 
  guid3DAlgorithm.GUID
EndStructure

;Structure WAVEFORMATEX
;  nFormatTag.w
;  nChannels.w
;  lSamplesPerSec.l
;  lAvgBytesPerSec.l
;  nBlockAlign.w
;  nBitsPerSample.w
;  nSize.w
;EndStructure




Prototype.l SoundDecoder_Check(a.l,b.l,c.l)
Prototype.l SoundDecoder_Decode(a.l,b.l,c.l)
Prototype.l SoundDecoder_GetNbSamples()
Prototype.l SoundDecoder_GetRate()
Prototype.l SoundDecoder_GetNbChannels()

Procedure ___CreateSoundBufferFromOGG(*DS.IDirectSound8,Addr,Size)
  If *DS=0 Or Addr=0 Or Size<=0:ProcedureReturn 0:EndIf
  SoundDecoder_Check.SoundDecoder_Check
  SoundDecoder_Decode.SoundDecoder_Decode
  SoundDecoder_GetNbSamples.SoundDecoder_GetNbSamples
  SoundDecoder_GetRate.SoundDecoder_GetRate
  SoundDecoder_GetNbChannels.SoundDecoder_GetNbChannels
   

  ;-> Use this in the UserLib (instead of UseOGGSoundDecoder() ) does it work correctly? 
  ;!If DEFINED _PB_UseOGGSoundDecoder@0
  ;-
  ;!EXTRN _PB_SoundDecoder_Check@12
  ;!EXTRN _PB_SoundDecoder_Decode@12
  ;!EXTRN _PB_SoundDecoder_GetNbSamples@0
  ;!EXTRN _PB_SoundDecoder_GetRate@0
  ;!EXTRN _PB_SoundDecoder_GetNbChannels@0
  ;-
  
  ;!else
  ;!_PB_SoundDecoder_Check@12:
  ;!_PB_SoundDecoder_Decode@12:
  ;!_PB_SoundDecoder_GetNbSamples@0:
  ;!_PB_SoundDecoder_GetRate@0:
  ;!_PB_SoundDecoder_GetNbChannels@0:
  ;ProcedureReturn 0
  ;!End if
  
  
  ;!MOV dword[p.v_SoundDecoder_Check],_PB_SoundDecoder_Check@12
  ;!MOV dword[p.v_SoundDecoder_Decode],_PB_SoundDecoder_Decode@12
  
  ;!MOV dword[p.v_SoundDecoder_GetNbSamples],_PB_SoundDecoder_GetNbSamples@0
  ;!MOV dword[p.v_SoundDecoder_GetRate],_PB_SoundDecoder_GetRate@0
  ;!MOV dword[p.v_SoundDecoder_GetNbChannels],_PB_SoundDecoder_GetNbChannels@0
  
  If SoundDecoder_Check(0,Addr,Size)=0:ProcedureReturn 0:EndIf
  wfx.WAVEFORMATEX\wFormatTag=#WAVE_FORMAT_PCM
  wfx\nChannels=SoundDecoder_GetNbChannels()
  wfx\nSamplesPerSec=SoundDecoder_GetRate()
  wfx\wBitsPerSample=16
  wfx\nBlockAlign=wfx\wBitsPerSample/8*wfx\nChannels 
  wfx\nAvgBytesPerSec=wfx\nSamplesPerSec*wfx\nBlockAlign
  
  sb.DSBUFFERDESC\dwSize=SizeOf(DSBUFFERDESC)
  sb\dwFlags=#DSBCAPS_CTRLFREQUENCY|#DSBCAPS_CTRLPAN|#DSBCAPS_CTRLVOLUME 
  sb\dwBufferBytes=(16/8)*SoundDecoder_GetNbSamples()*SoundDecoder_GetNbChannels()
  sb\lpwfxFormat=wfx
  
  Result=*DS\CreateSoundBuffer(sb,@*SB.IDirectSoundBuffer8,0) 
  If Result:ProcedureReturn 0:EndIf
  
  Result=*SB\Lock(0,0,@*ptr,@Size,0,0,#DSBLOCK_ENTIREBUFFER)
  If Result:*SB\Release():ProcedureReturn 0:EndIf   
  Result=SoundDecoder_Decode(*ptr,sb\dwBufferBytes,0) 
  *SB\UnLock(*ptr,Size,0,0)
  If Result=0:*SB\Release():ProcedureReturn 0:EndIf
  
  ProcedureReturn *SB
  ;UseOGGSoundDecoder() ;-> REMOVE REMOVE not good solution !(makes EXE/DLL much bigger!)
EndProcedure
    
    
Procedure ___CreateSoundBufferFromWAVE(*DS.IDirectSound8,*ptr)
  If *DS=0 Or *ptr=0:ProcedureReturn 0:EndIf
  
  If PeekS(*ptr,4)<>"RIFF":ProcedureReturn 0:EndIf
  *ptr+8:If PeekS(*ptr,8)<>"WAVEfmt ":ProcedureReturn 0:EndIf
  *ptr+8:If PeekL(*ptr)<>SizeOf(PCMWAVEFORMAT):ProcedureReturn 0:EndIf
  *ptr+4:RtlMoveMemory_(wfx.PCMWAVEFORMAT,*ptr,SizeOf(PCMWAVEFORMAT))
  *ptr+SizeOf(PCMWAVEFORMAT)
  If PeekS(*ptr,4)<>"data":ProcedureReturn 0:EndIf
  *ptr+4:BufferSize=PeekL(*ptr)
  
  sb.DSBUFFERDESC\dwSize=SizeOf(DSBUFFERDESC)
  sb\dwFlags=#DSBCAPS_CTRLFREQUENCY|#DSBCAPS_CTRLPAN|#DSBCAPS_CTRLVOLUME 
  sb\dwBufferBytes=BufferSize
  sb\lpwfxFormat=wfx
  
  Result=*DS\CreateSoundBuffer(sb,@*SB.IDirectSoundBuffer8,0) 
  
  If Result:ProcedureReturn 0:EndIf
  
  Result=*SB\Lock(0,0,@*bptr,@bsize,0,0,#DSBLOCK_ENTIREBUFFER)
  If Result:*SB\Release():ProcedureReturn 0:EndIf   
  RtlMoveMemory_(*bptr,*ptr+4,BufferSize) 
  *SB\UnLock(*bptr,bsize,0,0)
  
  ProcedureReturn *SB
EndProcedure


Global DS8_Inst
Global *DS8_DS.IDirectSound8
Global *DS8_PDSB.IDirectSoundBuffer8
Global DS8_hWnd
Global DS8_BufferList
Global DS8_BufferListSize

Procedure DS8_FreeSound()
  If DS8_BufferList
    For *ptr=DS8_BufferList To DS8_BufferList+DS8_BufferListSize-1 Step 4
      If PeekL(*ptr)
        *DSB.IUnknown=PeekL(*ptr)
        *DSB\Release()
        PokeL(*ptr,0)
        ProcedureReturn *DSB
      EndIf
    Next
    GlobalFree_(DS8_BufferList)
    DS8_BufferList=0
  EndIf
  DS8_BufferListSize=0
  If *DS8_PDSB:*DS8_PDSB\Release():*DS8_PDSB=0:EndIf
  If *DS8_DS:*DS8_DS\Release():*DS8_DS=0:EndIf
  If DS8_Inst:FreeLibrary_(DS8_Inst):DS8_Inst=0:EndIf
EndProcedure

Procedure DS8_FreeDevice()
  If DS8_BufferList
    For *ptr=DS8_BufferList To DS8_BufferList+DS8_BufferListSize-1 Step 4
      If PeekL(*ptr)
        *DSB.IUnknown=PeekL(*ptr)
        *DSB\Release()
        PokeL(*ptr,0)
        ProcedureReturn *DSB
      EndIf
    Next
  EndIf
  If *DS8_PDSB:*DS8_PDSB\Release():*DS8_PDSB=0:EndIf
EndProcedure

Procedure DS8_InitSound()
  DS8_FreeSound()
  
  DS8_BufferListSize=4
  DS8_BufferList=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,DS8_BufferListSize)
  If DS8_BufferList=0:ProcedureReturn 0:EndIf
  
  DS8_Inst=LoadLibrary_("dsound.dll")
  If DS8_Inst=0:DS8_FreeSound():ProcedureReturn 0:EndIf
  
  DirectSoundCreate8=GetProcAddress_(DS8_Inst,"DirectSoundCreate8")
  
  If DirectSoundCreate8=0:DS8_FreeSound():EndIf
  
  CallFunctionFast(DirectSoundCreate8,0,@*DS8_DS,0)
  
  If *DS8_DS=0:DS8_FreeSound():ProcedureReturn 0:EndIf
  
  ProcedureReturn *DS8_DS
EndProcedure

Procedure DS8_CreateDevice(hWnd)
  DS8_FreeDevice()
  If *DS8_DS=0:ProcedureReturn 0:EndIf
  If IsWindow_(hWnd)=0:hWnd=GetForegroundWindow_():EndIf
  DS8_hWnd=hWnd
  
  Result=*DS8_DS\SetCooperativeLevel(hWnd,#DSSCL_NORMAL)
  If Result:ProcedureReturn 0:EndIf
  
  psb.DSBUFFERDESC 
  psb\dwSize=SizeOf(DSBUFFERDESC)
  psb\dwFlags=#DSBCAPS_PRIMARYBUFFER
  
  Result=*DS8_DS\CreateSoundBuffer(psb,@*DS8_PDSB.IDirectSoundBuffer8,0) 
  If Result:ProcedureReturn 0:EndIf
  
  ProcedureReturn *DS8_PDSB
EndProcedure

Procedure DS8_LoadSoundBufferFromMem(Addr,Size)
  If *DS8_PDSB=0:DS8_CreateDevice(0):EndIf
  If *DS8_PDSB=0:ProcedureReturn 0:EndIf
  If DS8_BufferList=0 Or DS8_BufferListSize<=0:ProcedureReturn 0:EndIf
  
  *DSB.IDirectSoundBuffer8=___CreateSoundBufferFromWAVE(*DS8_DS,Addr)
  If *DSB=0
    *DSB=___CreateSoundBufferFromOGG(*DS8_DS,Addr,Size)
  EndIf
  
  If *DSB=0:ProcedureReturn 0 :EndIf
  
  For *ptr=DS8_BufferList To DS8_BufferList+DS8_BufferListSize-1 Step 4
    If PeekL(*ptr)=0
      PokeL(*ptr,*DSB)
      ProcedureReturn *DSB
    EndIf
  Next
  
  NewBufferList=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,DS8_BufferListSize+4)
  If NewBufferList=0
    *DSB\Release()
    ProcedureReturn 0
  EndIf
  
  RtlMoveMemory_(NewBufferList,DS8_BufferList,DS8_BufferListSize)
  PokeL(NewBufferList+DS8_BufferListSize,*DSB)
  GlobalFree_(DS8_BufferList)
  DS8_BufferList=NewBufferList
  DS8_BufferListSize+4
  ProcedureReturn *DSB
EndProcedure


Procedure DS8_LoadSoundBufferFromFile(File$)
  
  Handle=CreateFile_(File$,#GENERIC_READ,#FILE_SHARE_READ,0,#OPEN_EXISTING,#FILE_ATTRIBUTE_NORMAL,0)
  If Handle=0:ProcedureReturn 0:EndIf
  
  GetFileSizeEx_(Handle,s.LARGE_INTEGER)
  If s\highpart Or s\lowpart<=0:CloseHandle_(Handle):ProcedureReturn 0:EndIf
  
  *ptr=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,s\lowpart)
  If *ptr=0:CloseFile(Handle):ProcedureReturn 0:EndIf
  
  Result=ReadFile_(Handle,*ptr,s\lowpart,@numreadbytes,0)
  CloseHandle_(Handle)
  
  If Result=0
    GlobalFree_(*ptr)
    ProcedureReturn 0
  EndIf
  Result=DS8_LoadSoundBufferFromMem(*ptr,s\lowpart)
  GlobalFree_(*ptr)
  ProcedureReturn Result
EndProcedure


Procedure DS8_FreeSoundBuffer(*DSB.IDirectSoundBuffer8)
  If *DSB
    ; Remove the sound buffer from the list
    If DS8_BufferList
      For *ptr=DS8_BufferList To DS8_BufferList+DS8_BufferListSize-1 Step 4
        If PeekL(*ptr)=*DSB
          PokeL(*ptr,0)
          ProcedureReturn *DSB
        EndIf
      Next
    EndIf
    *DSB\Release()
  EndIf
EndProcedure

Procedure DS8_PlaySoundBuffer(*DSB.IDirectSoundBuffer8,looping)
  If *DSB
    *DSB\SetCurrentPosition(0)
    If looping
      Result=*DSB\Play(0,0,#DSBPLAY_LOOPING)
    Else
      Result=*DSB\Play(0,0,0)      
    EndIf
    If Result=0:ProcedureReturn 1:EndIf
  EndIf
EndProcedure

Procedure DS8_SetSoundBufferFrequency(*DSB.IDirectSoundBuffer8,Freq)
  If *DSB
    If Freq<100:Freq=100:EndIf  ; 100 or 1000 ????????
    If Freq>100000:Freq=100000:EndIf 
    If *DSB\SetFrequency(Freq)=0:ProcedureReturn 1:EndIf
  EndIf
EndProcedure

Procedure DS8_SetSoundBufferVolume(*DSB.IDirectSoundBuffer8,Volume)
  If *DSB
    If Volume<0:Volume=0:EndIf
    If Volume>100:Volume=100:EndIf
    
    Vol=-10000
    If Volume>0
      Vol=-Round(4000-Log(Volume)/Log(100)*4000,1)
    EndIf
    If *DSB\SetVolume(Vol)=0:ProcedureReturn 1:EndIf
  EndIf
EndProcedure


Procedure DS8_SetSoundBufferPan(*DSB.IDirectSoundBuffer8,Pan)
  If *DSB
    If Pan>0
      p=Round(4000-Log(100-Pan)/Log(100)*4000,1)
    Else
      p=-Round(4000-Log(100+Pan)/Log(100)*4000,1)
    EndIf
    
    If Pan>=100
      p=10000
    EndIf
    
    If Pan<=-100
      p=-10000
    EndIf
    If *DSB\SetPan(p)=0:ProcedureReturn 1:EndIf
  EndIf
EndProcedure

Procedure DS8_StopSound(*DSB.IDirectSoundBuffer8)
  If *DSB 
    If *DSB\Stop()=0:ProcedureReturn 1:EndIf  
     
  Else   
    If DS8_BufferList
      For *ptr=DS8_BufferList To DS8_BufferList+DS8_BufferListSize-1 Step 4
        If PeekL(*ptr)<>0
          *DSB.IDirectSoundBuffer8=PeekL(*ptr)
          *DSB\Stop()
        EndIf
      Next
      ProcedureReturn 1
    EndIf
    
  EndIf
EndProcedure



; IDE Options = PureBasic 4.10 Beta 1 (Windows - x86)
; CursorPosition = 267
; FirstLine = 256
; Folding = ---