Procedure.s UADD(A$,B$)
  Erg$=""
  If FindString(A$,".",1)=0:A$=A$+".0":EndIf
  If FindString(B$,".",1)=0:B$=B$+".0":EndIf
 
  PointA=FindString(A$,".",1)
  If PointA=0:PointA=Len(A$):EndIf
 
  PointB=FindString(B$,".",1)
  If PointB=0:PointB=Len(B$):EndIf
 
  If PointA>PointB:B$=LSet("",PointA-PointB,"0")+B$:EndIf
  If PointB>PointA:A$=LSet("",PointB-PointA,"0")+A$:EndIf
 
  If Len(A$)>Len(B$):B$=B$+LSet("",Len(A$)-Len(B$),"0"):EndIf
  If Len(B$)>Len(A$):A$=A$+LSet("",Len(B$)-Len(A$),"0"):EndIf
 
  Old=0
  For M=Len(A$) To 1 Step -1
    If Mid(A$,M,1)<>"."
      A=Val(Mid(A$,M,1))
      b=Val(Mid(B$,M,1))
      C=A+b+Old
      C$=Str(C)
      Old=0
      If C>9:Old=Val(Left(C$,1)):C$=Right(C$,1):EndIf
      Erg$=C$+Erg$
    Else
      Erg$="."+Erg$
    EndIf
  Next
  If Old<>0:Erg$=Str(Old)+Erg$:EndIf
  ProcedureReturn Erg$
EndProcedure
     
Debug UADD("7654321.12345","999000.000999")

Debug 7654321.12345+999000.000999
