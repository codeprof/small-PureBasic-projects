;####################################################
;# DX9Subsystem ObjectManager ©2006 Stefan Moebius  #
;####################################################

;----------------------------------------------------
; _PB_Object functions don't work correctly(crashes sometimes ?!?), function to free the list missing

;Procedure O_Init(Size,StepSize,FreeCB)
;  !extrn _PB_Object_Init@12
;  !JMP _PB_Object_Init@12
;EndProcedure

;Procedure O_GetObject(Objects,Number)
;  !extrn _PB_Object_GetObject@8
;  !JMP _PB_Object_GetObject@8
;EndProcedure

;Procedure O_IsObject(Objects,Number)
;  !extrn _PB_Object_IsObject@8
;  !JMP _PB_Object_IsObject@8
;EndProcedure

;Procedure O_FreeID(Objects,Number)
;  !extrn _PB_Object_FreeID@8
;  !JMP _PB_Object_FreeID@8
;EndProcedure

;Procedure O_GetOrAllocateID(Objects,Number)
;  !extrn _PB_Object_GetOrAllocateID@8
;  !JMP _PB_Object_GetOrAllocateID@8
;EndProcedure

;Procedure O_EnumerateStart(Objects)
;  !extrn _PB_Object_EnumerateStart@4
;  !JMP _PB_Object_EnumerateStart@4
;EndProcedure

;Procedure O_EnumerateNext(Objects,*PtrNumber)
;  !extrn _PB_Object_EnumerateNext@8
;  !JMP _PB_Object_EnumerateNext@8
;EndProcedure

;----------------------------------------------------

#HEAP_NO_SERIALIZE=1      
#HEAP_GROWABLE=2      
#HEAP_GENERATE_EXCEPTIONS=4      
#HEAP_ZERO_MEMORY=8  

Structure O_Objects
  StructureSize.l
  StepSize.l
  FreeCB.l
  ObjectsListNumEntries.l
  ObjectsList.l
  NumPBAnyLists.l
  PBAnyLists.l
EndStructure

Procedure O_Init(StructureSize,StepSize,*FreeCB)
  If StructureSize<=0:ProcedureReturn 0:EndIf
  If StepSize<=0:StepSize=1:EndIf
  *obj.O_Objects=HeapAlloc_(GetProcessHeap_(),0,SizeOf(O_Objects))
  If *obj=0:ProcedureReturn 0:EndIf
  *obj\StructureSize=StructureSize
  *obj\StepSize=StepSize
  *obj\FreeCB=*FreeCB
  *obj\ObjectsListNumEntries=StepSize
  *obj\ObjectsList=HeapAlloc_(GetProcessHeap_(),#HEAP_ZERO_MEMORY,StructureSize*StepSize)
  If *obj\ObjectsList=0:HeapFree_(GetProcessHeap_(),0,*obj):ProcedureReturn 0:EndIf
  
  *obj\NumPBAnyLists=1
  *obj\PBAnyLists=HeapAlloc_(GetProcessHeap_(),#HEAP_ZERO_MEMORY,4)
  If *obj\PBAnyLists=0:HeapFree_(GetProcessHeap_(),0,*obj\ObjectsList):HeapFree_(GetProcessHeap_(),0,*obj):ProcedureReturn 0:EndIf
  PBAnyList=HeapAlloc_(GetProcessHeap_(),#HEAP_ZERO_MEMORY,StructureSize*StepSize)
  If PBAnyList=0
    HeapFree_(GetProcessHeap_(),0,*obj\PBAnyLists)
    HeapFree_(GetProcessHeap_(),0,*obj\ObjectsList)
    HeapFree_(GetProcessHeap_(),0,*obj)
    ProcedureReturn 0
  EndIf
  PokeL(*obj\PBAnyLists,PBAnyList)
  
  ProcedureReturn *obj
EndProcedure

Procedure O_IsObject(*obj.O_Objects,Number)
  If *obj=0:ProcedureReturn 0:EndIf
  If Number=#PB_Any:ProcedureReturn 0:EndIf
    For c=0 To *obj\NumPBAnyLists-1
      *Addr=PeekL(*obj\PBAnyLists+c*4)
      If Number>=*Addr And Number<*Addr+*obj\StepSize * *obj\StructureSize
        If (Number-*Addr)%*obj\StructureSize:ProcedureReturn 0:EndIf
        If PeekL(Number)=0:ProcedureReturn 0:EndIf
        ProcedureReturn Number
      EndIf
    Next
  If Number>*obj\ObjectsListNumEntries-1:ProcedureReturn 0:EndIf
  If PeekL(*obj\ObjectsList+*obj\StructureSize*Number)=0:ProcedureReturn 0:EndIf
  ProcedureReturn *obj\ObjectsList+*obj\StructureSize*Number
EndProcedure

Procedure O_FreeObject(*obj.O_Objects,Number)
  If *obj=0:ProcedureReturn 0:EndIf
  *ptr=O_IsObject(*obj,Number)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *obj\FreeCB:CallFunctionFast(*obj\FreeCB,*obj,*ptr):EndIf
  RtlZeroMemory_(*ptr,*obj\StructureSize)
  ProcedureReturn 1
EndProcedure

Procedure O_GetOrAllocateID(*obj.O_Objects,Number)
  If *obj=0:ProcedureReturn 0:EndIf
  If Number=#PB_Any
    For Lists=0 To *obj\NumPBAnyLists-1
      *Addr=PeekL(*obj\PBAnyLists+Lists*4)
      For c=0 To *obj\StepSize-1
        If PeekL(*Addr+c * *obj\StructureSize)=0
          ProcedureReturn *Addr+c * *obj\StructureSize
        EndIf
      Next
    Next  
    *newptr=HeapReAlloc_(GetProcessHeap_(),#HEAP_ZERO_MEMORY,*obj\PBAnyLists,(*obj\NumPBAnyLists+1)*4)
    If *newptr=0:ProcedureReturn 0:EndIf
    *obj\PBAnyLists=*newptr
    PBAnyList=HeapAlloc_(GetProcessHeap_(),#HEAP_ZERO_MEMORY,*obj\StructureSize * *obj\StepSize)
    If PBAnyList=0:ProcedureReturn 0:EndIf ; don't free *newptr, hopefully HeapReAlloc works also when the size doesn't change
    PokeL(*newptr+*obj\NumPBAnyLists*4,PBAnyList)
    *obj\NumPBAnyLists+1
    ProcedureReturn PBAnyList
  Else
    If Number>*obj\ObjectsListNumEntries-1
      *newptr=HeapReAlloc_(GetProcessHeap_(),#HEAP_ZERO_MEMORY,*obj\ObjectsList,(Number+*obj\StepSize)* *obj\StructureSize)
      If *newptr=0:ProcedureReturn 0:EndIf
      *obj\ObjectsList=*newptr
      *obj\ObjectsListNumEntries=(Number+*obj\StepSize)
      ProcedureReturn *newptr+Number * *obj\StructureSize
    EndIf
    O_FreeObject(*obj,Number)
    ProcedureReturn *obj\ObjectsList+Number* *obj\StructureSize   
  EndIf
EndProcedure

Procedure O_EnumAllEntries(*obj.O_Objects,*CB)
  If *obj=0 Or *CB=0:ProcedureReturn 0:EndIf 
  For Lists=0 To *obj\NumPBAnyLists-1
    For c=0 To *obj\StepSize-1
      If PeekL(PeekL(*obj\PBAnyLists+Lists*4)+c* *obj\StructureSize)
        CallFunctionFast(*CB,*obj,PeekL(*obj\PBAnyLists+Lists*4)+c * *obj\StructureSize)
      EndIf
    Next
  Next
    For c=0 To *obj\ObjectsListNumEntries-1
      If PeekL(*obj\ObjectsList+c* *obj\StructureSize)
      CallFunctionFast(*CB,*obj,*obj\ObjectsList+c * *obj\StructureSize)
    EndIf
  Next  
  ProcedureReturn 1
EndProcedure

Procedure ___iO_CB(*obj.O_Objects,*ptr)
  CallFunctionFast(*obj\FreeCB,*obj,*ptr)
EndProcedure


Procedure O_Free(*obj.O_Objects)
  If *obj=0:ProcedureReturn 0:EndIf
  If *obj\FreeCB:O_EnumAllEntries(*obj,@___iO_CB()):EndIf
  HeapFree_(GetProcessHeap_(),0,*obj\ObjectsList)
  For c=0 To *obj\NumPBAnyLists-1
  HeapFree_(GetProcessHeap_(),0,PeekL(*obj\PBAnyLists+c*4))
  Next
  HeapFree_(GetProcessHeap_(),0,*obj\PBAnyLists)
  HeapFree_(GetProcessHeap_(),0,*obj)
  ProcedureReturn 1
EndProcedure

;Test:

;Structure Test
;test.l
;dummy.l
;EndStructure

;Procedure Test_Free(*obj,*ptr)
;Debug "Free Object "+Str(PeekL(*ptr))
;EndProcedure

;*obj.O_Objects=O_Init(SizeOf(Test),10,@Test_Free())

;Debug "*obj "+Str(*obj)
;For G=0 To 1000
;A=O_GetOrAllocateID(*obj,-1)
;PokeL(A,G)
;Debug A
;Debug O_IsObject(*obj,G)
;Next

;O_Free(*obj)

; IDE Options = PureBasic v4.00 (Windows - x86)
; CursorPosition = 148
; FirstLine = 128
; Folding = --