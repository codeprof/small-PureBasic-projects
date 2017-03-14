	

    #IDI_SHIELD = 32518
    #JobObjectBasicUIRestrictions = 4
    #JOB_OBJECT_UILIMIT_HANDLES = 1
     
    Prototype.i __CreateJobObject(*pSa.i,*pName.i)
    Prototype.i __OpenJobObject(*pSa.i,bInheritHandles.i, *pName.i)
    Prototype.i __SetInformationJobObject(hJob.i, JobObjectInfoClass.i, lpJobObjectInfo.i, cbJobObjectInfoLength.i)
    Prototype.i __AssignProcessToJobObject(hJob.i, hProcess.i)
    Prototype.i __UserHandleGrantAccess(hUserHandle.i, hJob.i, bGrant.i)
    Prototype.i __GetShellWindow()
    Prototype.i __TerminateJobObject(hJob.i,iExit.i)
     
    Structure JOBOBJECT
    hJob.i
    hKernel32.i
    hUser32.i
    CreateJobObject.__CreateJobObject
    OpenJobObject.__OpenJobObject
    SetInformationJobObject.__SetInformationJobObject
    AssignProcessToJobObject.__AssignProcessToJobObject
    UserHandleGrantAccess.__UserHandleGrantAccess
    GetShellWindow.__GetShellWindow
    TerminateJobObject.__TerminateJobObject
    EndStructure
     
    Global g_Job.JOBOBJECT
     
    Procedure JOB_Create()
    g_Job\hJob = #Null
    g_Job\hKernel32 = LoadLibrary_("Kernel32.dll")
    g_Job\hUser32 = LoadLibrary_("User32.dll")
     
    If g_Job\hKernel32 And g_Job\hUser32
      g_Job\CreateJobObject = GetProcAddress_(g_Job\hKernel32, "CreateJobObjectA")
      g_Job\OpenJobObject = GetProcAddress_(g_Job\hKernel32, "OpenJobObjectA")
      g_Job\SetInformationJobObject = GetProcAddress_(g_Job\hKernel32, "SetInformationJobObject")
      g_Job\AssignProcessToJobObject = GetProcAddress_(g_Job\hKernel32, "AssignProcessToJobObject")
      g_Job\UserHandleGrantAccess = GetProcAddress_(g_Job\hUser32, "UserHandleGrantAccess")
      g_Job\GetShellWindow = GetProcAddress_(g_Job\hUser32, "GetShellWindow")
      g_Job\TerminateJobObject = GetProcAddress_(g_Job\hKernel32, "TerminateJobObject")
     
    Debug g_Job\TerminateJobObject
     
      If g_Job\OpenJobObject And g_Job\CreateJobObject And g_Job\SetInformationJobObject And g_Job\AssignProcessToJobObject And g_Job\UserHandleGrantAccess And g_Job\GetShellWindow
        g_Job\hJob = g_Job\OpenJobObject($1F001F, #False, @"UserJOB")
        Debug "OpenJob "+Str(g_Job\hJob )
        If g_Job\hJob = 0
          g_Job\hJob = g_Job\CreateJobObject(#Null,  @"UserJOB")
              Debug "CreateJob "+Str(g_Job\hJob )
        EndIf
      EndIf
    EndIf
     
    If g_Job\hJob = #Null
      If g_Job\hKernel32:FreeLibrary_(g_Job\hKernel32):EndIf
      If g_Job\hUser32:FreeLibrary_(g_Job\hUser32):EndIf
      g_Job\hKernel32 = #Null
      g_Job\hUser32 = #Null
    EndIf
     
    ProcedureReturn g_Job\hJob
    EndProcedure
     
     
    Procedure JOB_InitUserObjects()
      If g_Job\hJob And g_Job\UserHandleGrantAccess And g_Job\SetInformationJobObject And g_Job\GetShellWindow And g_Job\AssignProcessToJobObject
     
        lRestriction.l = #JOB_OBJECT_UILIMIT_HANDLES
        If g_Job\SetInformationJobObject(g_Job\hJob, #JobObjectBasicUIRestrictions, @lRestriction, SizeOf(LONG))
     
          g_Job\UserHandleGrantAccess(GetDesktopWindow_(),g_Job\hJob,#True)  
          g_Job\UserHandleGrantAccess(g_Job\GetShellWindow(),g_Job\hJob,#True)  
          g_Job\UserHandleGrantAccess(#HWND_BROADCAST,g_Job\hJob,#True)
          ;g_Job\UserHandleGrantAccess(CallFunction(2,"GetTaskmanWindow"),g_Job\hJob,#True)
         
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_APPSTARTING),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_ARROW),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_CROSS),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_HAND),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_HELP),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_IBEAM),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_ICON),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_NO),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_SIZE),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_SIZEALL),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_SIZENESW),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_SIZENS),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_SIZENWSE),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_SIZEWE),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_UPARROW),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadCursor_(#Null,#IDC_WAIT),g_Job\hJob,#True)
         
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_APPLICATION),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_ASTERISK),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_ERROR),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_EXCLAMATION),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_HAND),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_INFORMATION),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_QUESTION),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_WARNING),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_WINLOGO),g_Job\hJob,#True)
          g_Job\UserHandleGrantAccess(LoadIcon_(#Null,#IDI_SHIELD),g_Job\hJob,#True)
          Debug "ok"
        EndIf
      EndIf  
    EndProcedure
     
     
    Procedure JOB_AssignProcessToJob(hProcess.i)
      If hProcess = #Null:hProcess = GetCurrentProcess_():EndIf
      Debug "process to job: "+Str(hProcess)
      ProcedureReturn g_Job\AssignProcessToJobObject(g_Job\hJob, hProcess)
    EndProcedure
     
    Procedure JOB_ProtectUserObjects()
      If g_Job\hJob And g_Job\SetInformationJobObject
        ;lRestriction.l = 0
        ;g_Job\SetInformationJobObject(g_Job\hJob, #JobObjectBasicUIRestrictions, @lRestriction, SizeOf(LONG))
        lRestriction.l = #JOB_OBJECT_UILIMIT_HANDLES
        g_Job\SetInformationJobObject(g_Job\hJob, #JobObjectBasicUIRestrictions, @lRestriction, SizeOf(LONG))
      EndIf
    EndProcedure
     
    Procedure JOB_UnProtectUserObjects()
      If g_Job\hJob And g_Job\SetInformationJobObject
        ; Reset restrictions, so we have acess to all user object
        lRestriction.l = 0
        ProcedureReturn g_Job\SetInformationJobObject(g_Job\hJob, #JobObjectBasicUIRestrictions, @lRestriction, SizeOf(LONG))
      EndIf
      ProcedureReturn #False
    EndProcedure
     
    Procedure JOB_Close()
      JOB_UnProtectUserObjects()
      If g_Job\hJob
        CloseHandle_(g_Job\hJob)
        g_Job\hJob = #Null
        If g_Job\hKernel32:FreeLibrary_(g_Job\hKernel32):EndIf
        If g_Job\hUser32:FreeLibrary_(g_Job\hUser32):EndIf
        g_Job\hKernel32 = #Null
        g_Job\hUser32 = #Null
      EndIf
    EndProcedure

