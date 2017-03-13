;Licence: Public domain
EnableExplicit
Structure THROTTLE_CPU
  hThread.i
  pauseFactor.i
EndStructure  

Procedure __ThPause(*params.THROTTLE_CPU)
  Protected timecaps.TIMECAPS, exitCode.i   
  If *params <> #Null
    timeGetDevCaps_(timecaps,SizeOf(TIMECAPS))  
    timeBeginPeriod_(timecaps\wPeriodMin)
    Repeat
      If GetExitCodeThread_(*params\hThread, @exitCode)      
        If exitCode <> #STILL_ACTIVE
          ; for the main thread this would be to late(process already terminated) however we could also use only repeat...forever here       
          Break
        EndIf 
      EndIf  
      SuspendThread_(*params\hThread)
      Sleep_(*params\pauseFactor)  
      ResumeThread_(*params\hThread)
      Sleep_(1)
    ForEver
    timeEndPeriod_(timecaps\wPeriodMin)
    CloseHandle_(*params\hThread)
    FreeMemory(*params)
  EndIf
EndProcedure

Procedure ThrottleCPU(pauseFactor.i)
  Protected *params.THROTTLE_CPU = AllocateMemory(SizeOf(THROTTLE_CPU))
  If *params
    *params\pauseFactor = pauseFactor
    If DuplicateHandle_(GetCurrentProcess_(),GetCurrentThread_(), GetCurrentProcess_(), @*params\hThread, #THREAD_GET_CONTEXT, #False, #DUPLICATE_SAME_ACCESS)
      ProcedureReturn CreateThread(@__ThPause(), *params) 
    Else
      FreeMemory(*params)
    EndIf  
  EndIf
  ProcedureReturn #Null
EndProcedure



;Example
ThrottleCPU(100)

OpenWindow(0, 0, 0, 800, 800, "Highspeed drawing", #PB_Window_SystemMenu | #PB_Window_ScreenCentered) 
  
  Repeat
    StartDrawing(WindowOutput(0))
      LineXY(Random(800),Random(800),Random(800),Random(800),Random($FFFFFF))
    StopDrawing()
  Until WindowEvent() = #PB_Event_CloseWindow
