

; *************************************************************************************
; *
; *  Function:       nCPU_UseCPU (lFlags.l)
; *
; *  Description:    Decalares which CPU(s) should be used for the current thread.
; *
; *  Parameters:     lFlags.l    can be:
; *                              1: for the first processor
; *                              2: for the second processor
; *                              1+2: for the first and the second processor
; *
; *  Return:         If the function succeeds, the return value TRUE.
; *                  If the function fails, the return value is FALSE.
; *
; *************************************************************************************
 
ProcedureDLL.l nCPU_UseCPU(lCPU.l)
ProcedureReturn SetThreadAffinityMask_(GetCurrentThread_(),lCPU)
EndProcedure
 
 
; *************************************************************************************
; *
; *  Function:       nCPU_GetMhz ()
; *
; *  Description:    Returns the frequency of the Processor. (in MHz)
; *
; *  Parameters:     n/a
; *
; *  Return:         Look at description.
; *
; *************************************************************************************
 
ProcedureDLL.l nCPU_GetMhz()
  Protected SysInf.System_Info, dTime.d, lKey.l, lcpuid.l, lMHz.l, lResult.l, lSize.l=4, qticks1.q, qticks2.q, qFreq.q, qTime1.q, qTime2.q
 
  ; First try to get the value from the registry.( should work for Windows 2000 and Windows XP)
  lResult=RegOpenKeyEx_(#HKEY_LOCAL_MACHINE,"HARDWARE\DESCRIPTION\System\CentralProcessor\0",0,#KEY_ALL_ACCESS,@lKey)
  If lResult=#S_OK
    RegQueryValueEx_(lKey,"~MHz",0,0,@lMHz,@lSize)
    RegCloseKey_(lKey)
  EndIf
 
  If lMHz>0
    ProcedureReturn lMHz
  EndIf
 
  ; Ok, we can't get the value form the registry, so we must calculate it:
  ; This method may works not correctly, if the CPU runs not with full speed!
 
  GetSystemInfo_(SysInf)
  If SysInf\dwProcessorType<#PROCESSOR_INTEL_PENTIUM
    ; CPUID is supported since Pentium, and this processor is not at least a Pentium.
    ProcedureReturn 0 ; return zero, as we need CPUID.
  EndIf
 
  !MOV Eax, 1              
  !cpuid
  !MOV [p.v_lcpuid],Edx
 
  If (lcpuid>>4)&1=0 ; RDTSC available? (we need a Pentium Pro for this)
    ProcedureReturn 0 ; If not, return zero, as we need RDTSC.
  EndIf
 
  If QueryPerformanceFrequency_(@qFreq.q)=0
    ;high performance counter is not supported!
    ProcedureReturn 0 ; return zero, as we need a high performance counter.
  EndIf
  ; so now we can calculate the value, and hope that it is correct.
 
  QueryPerformanceCounter_(@qTime1.q)  ; we need to calculate the needed time, because Sleep(10) waits not exactly 10 ms.
  !RDTSC
  !MOV dword[p.v_qticks1],Eax
  !MOV dword[p.v_qticks1+4],Edx
 
  Sleep_(10) ; Wait some time... to get exacter values increase this value.(with 10 ms you should get good values.)
 
  !RDTSC
  !MOV dword[p.v_qticks2],Eax
  !MOV dword[p.v_qticks2+4],Edx
  QueryPerformanceCounter_(@qTime2.q)
 
  dTime.d=(qTime2-qTime1)/qFreq
 
  ProcedureReturn ((qticks2-qticks1)/dTime)*0.000001
EndProcedure
 
 
 
; *************************************************************************************
; *
; *  Function:       nCPU_GetNumber ()
; *
; *  Description:    Returns the number of processors in the system.
; *
; *  Parameters:     n/a
; *
; *  Return:         Look at description.
; *
; *************************************************************************************
 
ProcedureDLL.l nCPU_GetNumber()
  Protected SysInf.System_Info
  GetSystemInfo_(SysInf)
  ProcedureReturn SysInf\dwNumberOfProcessors
EndProcedure
