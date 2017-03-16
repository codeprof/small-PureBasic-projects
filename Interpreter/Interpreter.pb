

;#E: Empty
;#V: possible Variable
;#N: Number
;#F: Function/Array
;#S: String constant

;konwn errors:
;function((0))
;()
;(())
Global pos = 1
Global line.s
Global inString
Global inComment
Global layer_index = 0
Global NewMap token.s()
Global NewMap operators.s()
Global NewMap vars.s()
Global NewMap funcs.i()

#DATATYPE_UNKNOWN = 0
#DATATYPE_NUMBER = 1
#DATATYPE_STRING = 2

#SUPPORTED_OPERATORS = "~!;|&<>=-+*/^"
Procedure evalError(msg.s)
  Debug "ERROR:" + msg
  ;End
EndProcedure  

Procedure isValidVariable(str.s)
  If str = ""
    ProcedureReturn #False
  EndIf  
  
  If Not FindString("_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", Mid(str, 1,1))
    ProcedureReturn #False
  EndIf
  
  For i = 2 To Len(str)
    If Not FindString("_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", Mid(str, i, 1))
      ProcedureReturn #False
    EndIf  
  Next
  ProcedureReturn #True
EndProcedure

Procedure isValidNumber(str.s, allowSign)
  afterSign = #False
  If str = ""
    ProcedureReturn #False
  EndIf  
  
  For i = 1 To Len(str)
    ch.s = Mid(str, i, 1)
    If allowSign And (i=1) And (ch = "-")
      
    ElseIf ch = "." And dot = #False
      dot = #True
    Else
      If Not FindString("0123456789", ch)       
        ProcedureReturn #False
      EndIf      
    EndIf      
  Next
  ProcedureReturn #True
EndProcedure

Procedure isValidFunctionInternal(str.s)
  If str = ""
    ProcedureReturn #False
  EndIf  
  
  If CountString(str, "#") <> 1
    ;function does not fit internal Structure name#placeholder, name#placeholder1#placeholder2 is also Not allowed
    ProcedureReturn  #False
  EndIf  
  
  ;just check everything before #. The remaining part should be a vaild placeholder
  name.s = StringField(str, 1, "#")
  If isValidVariable(name)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure


Procedure.s analyzeOperand(str.s)
  ;Debug "ANALYZE:" +str
  sign.s = ""
  
  If Left(str,1) = "-" ; allow sign
    str = Trim(Right(str,Len(str)-1))
    sign.s = "-"
  EndIf  
  
  If str = ""
    evalError("operand is missing") 
  ElseIf FindString(str, " ")
    evalError("operator is missing")
  Else
    
    layer_index + 1
    key.s = Str(layer_index)   
    If Left(str, 1) = "#"     
      
    ElseIf isValidNumber(str, #False)
      key.s = "N" + key
      
    ElseIf isValidVariable(str)
      key.s = "V" + key    
      
    ElseIf isValidFunctionInternal(str)
      key.s = "F" + key
      
    Else
      If FindString(Str, "#")
        evalError("invalid operand") ; don't show internals
      Else  
        Debug evalError("invalid operand '" + str + "'")
      EndIf  
    EndIf
    token(key) = str
    ;tokensign(key) = sign   
    
    If sign <> ""
      layer_index + 1
      key2.s = Str(layer_index)
      token(key2) = sign + "#"+ key
      key = key2
    EndIf
    
    ProcedureReturn "#" + key   
    
  EndIf    
EndProcedure

Procedure.s ApplyOperator(str.s, op.s)
  If FindString(str, op)
    operators.s = StringField(str, 1, "#")
    operands.s = Right(str, Len(str) - (Len(operators.s) + 1)) ;also remove the first "#", so we can use the remeaing "#"'s as seperator easyly
                                                               ;Debug operators.s
                                                               ;Debug operands.s
    
    i = 1
    While FindString(operators.s, op)
      
      i = FindString(operators.s, op)
      layer_index + 1
      key.s = Str(layer_index) 
      token(key) = op.s + "#" + StringField(operands, i, "#") + "#" + StringField(operands, i+1, "#")
      
      ;Debug "ADD #" +key + " = " +op.s + "#" + StringField(operands, i, "#") + "#" + StringField(operands, i+1, "#")
      
      tmp_operands.s = ""
      
      For k = 1 To Len(operators.s)+1 ; Num operands
        If k = i 
          tmp_operands + key + "#"
        ElseIf k = i  + 1 
          ;do nothing
        Else
          tmp_operands + StringField(operands, k, "#") + "#"
        EndIf  
      Next  
      operators.s = Left(operators.s, i - 1) + Right(operators.s, Len(operators.s) - i) ; remove char at position i
      operands = Left(tmp_operands, Len(tmp_operands)-1)                                ; there is one "#" to much at the end 
      
    Wend
    ProcedureReturn operators.s + "#" + operands
  Else
    ProcedureReturn str
  EndIf
  
EndProcedure

Procedure.s ReplaceOperators(str.s)
  If FindString(str, "~", 1)
    evalError("'~' is not a vaild operator")
  EndIf  
  If FindString(str, "!", 1)
    evalError("'!' is not a vaild operator")
  EndIf 
  If FindString(str, ";", 1)
    evalError("';' is not a vaild operator")
  EndIf   
  
  str = ReplaceString(str, ">=", "~")
  str = ReplaceString(str, "<=", "!")  
  str = ReplaceString(str, "!=", ";")    
  str = ReplaceString(str, "<>", ";")   
  
  ProcedureReturn str
EndProcedure

Procedure.s ApplyOperators(str.s)
  
  str = ApplyOperator(str.s, "^")  
  str = ApplyOperator(str.s, "/")
  str = ApplyOperator(str.s, "*") 
  str = ApplyOperator(str.s, "-") 
  str = ApplyOperator(str.s, "+")  
  str = ApplyOperator(str.s, "=")   
  str = ApplyOperator(str.s, "~")
  str = ApplyOperator(str.s, "!")  
  str = ApplyOperator(str.s, "<") 
  str = ApplyOperator(str.s, ">") 
  str = ApplyOperator(str.s, ";")   
  str = ApplyOperator(str.s, "&") 
  str = ApplyOperator(str.s, "|")   
  
  ProcedureReturn str
EndProcedure  

Procedure.s splitOperators(str.s)
  str = Trim(str)
  If str = ""
    str = "#E"  ;allow () for functions  ;TODO: disallow (), (()), t(())
  EndIf
  
  tmp.s
  res.s = ""
  ops.s = ""
  For i=1 To Len(str)
    ch.s = Mid(str, i, 1)
    If FindString(#SUPPORTED_OPERATORS, ch)
      tmp = Trim(tmp)
      If tmp.s <> "" 
        res + analyzeOperand(tmp)       
        tmp = ""
        ;res + ch ;# can be used as seperator here
        ops + ch   ;Add operators to another list
        signadded = #False
      Else
        If ch <> "-" ;allow sign
          evalError("left operand missing")
        Else
          tmp + ch
        EndIf  
      EndIf    
    Else
      tmp + ch
    EndIf  
  Next
  tmp = Trim(tmp)  
  If tmp <> ""
    res + analyzeOperand(tmp)  
  Else
    evalError("right operand missing")
  EndIf  
  ProcedureReturn ops + res ;first the operators then the operands
EndProcedure

Procedure.s tokenize(layer)
  coll.s = ""
  While pos <= Len(line)    
    ch.s = Mid(line, pos, 1)
    pos+1
    If ch = "(" And (Not inString) And (Not inComment)
      layer_index+1
      coll + tokenize(layer_index)
    ElseIf ch = ")" And (Not inString) And (Not inComment)     
      token(Str(layer)) = ApplyOperators(splitOperators(ReplaceOperators(coll)))
      If layer = 0
        evalError("bracked was not opened before") 
      Else
        ProcedureReturn "#" + Str(layer)    
      EndIf
      
    ElseIf ch = "'" And Not inComment  
      inString = ~inString
      If inString
        layer_index+1
        coll + tokenize(layer_index)
      Else
        token("S"+Str(layer)) = "@"+coll  ; added @, to mark it as string      
        ProcedureReturn "#S" + Str(layer)    
      EndIf
      
    ElseIf ch = "#" And Not inString  
      inComment = #True     
    Else
      If Not inComment
        coll.s + ch  
      EndIf
    EndIf  
  Wend
  If inString Or layer > 0
    evalError("bracked not closed")
  Else  
    ProcedureReturn ApplyOperators(splitOperators(ReplaceOperators(coll)))
  EndIf  
EndProcedure

Procedure.s simplifySigns(str.s)
  numsigns = CountString(str, "-")
  If (numsigns & 1)  
    ProcedureReturn Right(str, Len(str) - (numsigns-1))
  Else
    ProcedureReturn Right(str, Len(str) - numsigns)     
  EndIf  
EndProcedure  

Procedure.s prepareOperator(str.s, *type.integer)
  *type\i =  #DATATYPE_UNKNOWN
  If Left(str,1) = "@"
    *type\i = #DATATYPE_STRING
    ProcedureReturn Right(str, Len(str)-1)
  Else
    str = simplifySigns(str)
    If isValidNumber(str, #True)
      *type\i = #DATATYPE_NUMBER     
    EndIf
  EndIf
  ProcedureReturn str  
EndProcedure  

Procedure.s evalOperator(operators.s, operand1.s, operand2.s)
  Debug "OP:" + operators.s +" " + operand1.s + " "+ operand2.s
  
  operand1 = prepareOperator(operand1, @type1)
  operand2 = prepareOperator(operand2, @type2)  
  
  If type1 = #DATATYPE_UNKNOWN
    evalError("Invalid type")
  EndIf  
  If type2 = #DATATYPE_UNKNOWN
    If (operators = "-") And operand2 = ""
      ;Just the sign operator, so everything ok!
    Else  
      evalError("Invalid type")
    EndIf
  EndIf  
  
  Select operators.s  
      
    Case "&"  
      If type1 = #DATATYPE_NUMBER
        If operand1 <> "0"
          res1 = #True
        Else
          res1 = #False
        EndIf  
      Else
        If operand1 <> ""
          res1 = #True
        Else
          res1 = #False
        EndIf    
      EndIf  
      
      If type2 = #DATATYPE_NUMBER
        If operand2 <> "0"
          res2 = #True
        Else
          res2 = #False
        EndIf  
      Else
        If operand2 <> ""
          res2 = #True
        Else
          res2 = #False
        EndIf    
      EndIf   
      
      If res1 And res2
        ProcedureReturn "1"
      Else
        ProcedureReturn "0"
      EndIf    
      
    Case "|"  
      If type1 = #DATATYPE_NUMBER
        If operand1 <> "0"
          res1 = #True
        Else
          res1 = #False
        EndIf  
      Else
        If operand1 <> ""
          res1 = #True
        Else
          res1 = #False
        EndIf    
      EndIf  
      
      If type2 = #DATATYPE_NUMBER
        If operand2 <> "0"
          res2 = #True
        Else
          res2 = #False
        EndIf  
      Else
        If operand2 <> ""
          res2 = #True
        Else
          res2 = #False
        EndIf    
      EndIf   
      
      If res1 Or res2
        ProcedureReturn "1"
      Else
        ProcedureReturn "0"
      EndIf      
      
    Case ";"  
      If operand1 = operand2
        ProcedureReturn "0"
      Else
        ProcedureReturn "1"
      EndIf
      
    Case "="
      If operand1 = operand2
        ProcedureReturn "1"
      Else
        ProcedureReturn "0"
      EndIf 
    Case ">"
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        If ValD(operand1) > ValD(operand2)
          ProcedureReturn "1"
        Else
          ProcedureReturn "0"
        EndIf 
      Else
        If CompareMemoryString(@operand1,@operand2) = #PB_String_Greater
          ProcedureReturn "1"
        Else
          ProcedureReturn "0"
        EndIf      
      EndIf     
    Case "<"
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        If ValD(operand1) < ValD(operand2)
          ProcedureReturn "1"
        Else
          ProcedureReturn "0"
        EndIf 
      Else
        If CompareMemoryString(@operand1,@operand2) = #PB_String_Lower
          ProcedureReturn "1"
        Else
          ProcedureReturn "0"
        EndIf      
      EndIf     
      
    Case "~" ;>=
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        If ValD(operand1) >= ValD(operand2)
          ProcedureReturn "1"
        Else
          ProcedureReturn "0"
        EndIf 
      Else
        res = CompareMemoryString(@operand1,@operand2) 
        If res = #PB_String_Greater Or res = #PB_String_Equal
          ProcedureReturn "1"
        Else
          ProcedureReturn "0"
        EndIf      
      EndIf     
    Case "!" ;<=
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        If ValD(operand1) <= ValD(operand2)
          ProcedureReturn "1"
        Else
          ProcedureReturn "0"
        EndIf 
      Else
        res = CompareMemoryString(@operand1,@operand2) 
        If res = #PB_String_Lower Or res = #PB_String_Equal
          ProcedureReturn "1"
        Else
          ProcedureReturn "0"
        EndIf      
      EndIf      
      
    Case "^"
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        ProcedureReturn StrD(Pow(ValD(operand1),ValD(operand2)))
      ElseIf type2 = #DATATYPE_NUMBER
        ProcedureReturn ReplaceString(Space(Val(operand2))," ", operand1)          
      Else
        ProcedureReturn ""   
      EndIf      
      
    Case "-"      
      If type1 = #DATATYPE_NUMBER And operand2 = "" ; sign    
        ProcedureReturn StrD(-ValD(operand1))      
        
      ElseIf type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        ProcedureReturn StrD(ValD(operand1)-ValD(operand2))
      Else
        ProcedureReturn ""    
      EndIf        
      
    Case "+"
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        ProcedureReturn StrD(ValD(operand1)+ValD(operand2))
      Else
        ProcedureReturn operand1+operand2    
      EndIf      
      
    Case "*"
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        ProcedureReturn StrD(ValD(operand1)*ValD(operand2))
      ElseIf type1 = #DATATYPE_NUMBER
        ProcedureReturn ReplaceString(Space(Val(operand1))," ", operand2)          
      ElseIf type2 = #DATATYPE_NUMBER
        ProcedureReturn ReplaceString(Space(Val(operand2))," ", operand1)
      Else
        ProcedureReturn ""   
      EndIf  
      
    Case "/"
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        ProcedureReturn StrD(ValD(operand1)/ValD(operand2))     
      Else
        ProcedureReturn ReplaceString(operand1, operand2, "")   ;without operator
      EndIf    
    Default
      ProcedureReturn ""
  EndSelect       
EndProcedure  




Procedure.s evalToken(tok.s)
  While Left(tok,1) = "#"
    Debug "RESOLVE:" + tok      
    last_tok.s = Right(tok, Len(tok)-1)  
    tok = token(last_tok.s)
    Debug "RESOLVED:" + tok
    ;     If tok = "" And last_tok = "E"
    ;       Debug "ERROR: Empty expression"
    ;     EndIf  
  Wend
  
  If Left(tok,1) = ","
    seperators.s = StringField(tok, 1, "#")
    params.s = Right(tok, Len(tok) - (Len(seperators.s) + 1)) ;also remove the first "#", so we can use the remeaing "#"'s as seperator easyly      
    
    tok = ""
    For i = 1 To Len(seperators)+1
      tok + EscapeString(evalToken("#"+StringField(params, i, "#")))+Chr(9) ; ecape parameters and seperate by tab (chr(9))
    Next  
    
  ElseIf FindString(#SUPPORTED_OPERATORS, Left(tok,1))
    
    operators.s = StringField(tok, 1, "#")
    operands.s = Right(tok, Len(tok) - (Len(operators.s) + 1)) ;also remove the first "#", so we can use the remeaing "#"'s as seperator easyly  
    
    op1.s = StringField(operands, 1, "#")
    op2.s = StringField(operands, 2, "#")    
    
    btok.s = tok
    If op2 = "" ;its a sign    
      tok = evalOperator(operators, evalToken("#"+op1), "")
    Else
      tok = evalOperator(operators, evalToken("#"+op1), evalToken("#"+op2))     
    EndIf  
    ;Debug "OPERATOR EVAL:" +btok + "          "+ tok
    
  ElseIf Left(last_tok,1) = "V"
    If FindMapElement(vars(), tok)
      tok = vars(tok)   
    Else
      tok = "0" ; use zero as default variable if not declared
    EndIf
  ElseIf Left(last_tok,1) = "F"  
    function.s = StringField(tok, 1, "#")
    params.s = evalToken("#" + StringField(tok, 2, "#"))
    Debug "FUNCTION:" + function
    Debug "PARAMS:" + params
    If FindMapElement(funcs(), function)
      tok = PeekS(CallFunctionFast(funcs(function), @params))
    Else
      evalError("function '" + function + "' is not implemented")
    EndIf  
  EndIf  
  
  Debug "RESULT:" + tok
  ProcedureReturn tok   
EndProcedure

Procedure.s evalExpression(str.s)
  ClearMap(token())
  ClearMap(operators())  
  pos = 1
  inString = #False
  inComment = #False  
  line = str
  tok.s = tokenize(0)
  
  Debug tok
  Debug "======"
  ForEach token()
    Debug  MapKey(token()) + "    =   "  + token()    
  Next 
  Debug "==================="
  
  ProcedureReturn prepareOperator(evalToken(tok), @dummy) ;prepareOperator because of problem if expression consists only out of a constant string (@-char)
EndProcedure  

Procedure evalLine(str.s)
  ClearMap(token())
  ClearMap(operators())  
  pos = 1
  inString = #False
  inComment = #False  
  line = str
  tok.s = tokenize(0)
  If Left(tok,1) =  "#" 
    tok.s = Right(tok, Len(tok)-1)  
    tok = token(tok.s)
  Else
    evalError("token expected")
  EndIf
  
  If Left(tok,2) = "=#"
    tok = Right(tok, Len(tok)-2)
    var.s = StringField(tok, 1, "#")
    exp.s = StringField(tok, 2, "#")
    
    If Left(var,1 ) = "V"
      vars(token(var)) = prepareOperator(evalToken("#"+exp), @dummy) ;prepareOperator because of problem if expression consists only out of a constant string (@-char)
    Else
      evalError("variable expected on left side")
    EndIf  
  Else
    evalError("assignment expected")
  EndIf  
EndProcedure


;binOr,binAnd,hex,...

Procedure.s my_cos(params)
  ProcedureReturn StrD(Cos(ValD(StringField(PeekS(params),1,Chr(9)))))
EndProcedure  

Procedure.s my_sin(params)
  ProcedureReturn StrD(Sin(ValD(StringField(PeekS(params),1,Chr(9)))))
EndProcedure  

Procedure.s my_msg(params)
  MessageRequester("",  StringField(PeekS(params),1,Chr(9)))
  ProcedureReturn ""
EndProcedure


vars("PI") = "3.1415926535897931"
vars("E") = "2.7182818284590451"


vars("a")= "1000.5"
vars("b")= "5"
vars("c5")="test"
funcs("cos") = @my_cos()
funcs("sin") = @my_sin()
funcs("msg") = @my_msg()

Debug evalLine("A=2")
Debug evalLine("B=7")
Debug evalLine("C=(A+B)*2")
Debug vars("C")


; Debug tokenize(0)
; 



