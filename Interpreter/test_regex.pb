

;#E: Empty
;#V: possible Variable
;#N: Number
;#F: Function/Array
;#S: String constant

;konwn errors:
;function((0))
;()
;(())


;supports:
;Arrays with arbitary dimensions!
;Call of Buildin functions
;Assignments
;Expressions
Global pos = 1
Global line.s
Global inString
Global inComment
Global layer_index = 0
Global syntaxcheck = #True

Global exec_dept = 0
Global NewMap token.s()
Global NewMap operators.s()
Global NewMap vars.s()

Global NewMap funcs.i()
Global NewMap arrNames.i()
Global NewMap arrsContent.s()

Global NewMap execDept.i()
Global NewMap execDeptCmd.s()
Global NewMap execGoto.i()

#DATATYPE_UNKNOWN = 0
#DATATYPE_NUMBER = 1
#DATATYPE_STRING = 2

#SUPPORTED_OPERATORS = ",~!;|&<>=-+*/^"

#REGEXP_VARIABLE = 1
#REGEXP_NUMBER = 2
#REGEXP_NUMBER_SIGNED = 3
CreateRegularExpression(#REGEXP_VARIABLE, "^([a-zA-Z_][a-zA-Z0-9_]*)$")
CreateRegularExpression(#REGEXP_NUMBER, "^(\d*\.?\d+)$")
CreateRegularExpression(#REGEXP_NUMBER_SIGNED, "^(\-?\d*\.?\d+)$")


Procedure evalError(msg.s)
  If syntaxcheck
    Debug "ERROR:" + msg
    End
  EndIf
EndProcedure  

Procedure isValidVariable(str.s)
    ProcedureReturn MatchRegularExpression(#REGEXP_VARIABLE, str)
EndProcedure

Procedure isValidNumber(str.s, allowSign)
  If allowSign
    ProcedureReturn MatchRegularExpression(#REGEXP_NUMBER_SIGNED, str)    
  Else
    ProcedureReturn MatchRegularExpression(#REGEXP_NUMBER, str)    
  EndIf
EndProcedure

Procedure isValidFunctionInternal(str.s)
  If str = ""
    ProcedureReturn #False
  EndIf  
  
  If CountString(str, "#") <> 1
    ;function does not fit internal Structure name#placeholder; name#placeholder1#placeholder2 is also Not allowed
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
        evalError("invalid operand '" + str + "'")
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
        evalError("bracket was not opened before") 
      Else
        ProcedureReturn "#" + Str(layer)    
      EndIf
      
    ElseIf ch = "'" And Not inComment  
      inString = ~inString
      If inString
        layer_index+1
        coll + tokenize(layer_index)
      Else
        token("S"+Str(layer)) = "@" + coll  ; added @, to mark it as string      
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
    evalError("bracket not closed")
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
  
  Debug "zzz"
  Debug operand1
  Debug operand2
  
  If type1 = #DATATYPE_UNKNOWN
    evalError("Invalid type5")
  EndIf  
  If type2 = #DATATYPE_UNKNOWN
    If (operators = "-") And (operand2 = "") And (type1 = #DATATYPE_NUMBER)
      ;Just the sign operator, so everything ok!
    Else  
      evalError("Invalid type4")
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
        ProcedureReturn "@"+ReplaceString(Space(Val(operand2))," ", operand1)          
      Else
        ProcedureReturn "@"   
      EndIf      
      
    Case "-"      
      If type1 = #DATATYPE_NUMBER And operand2 = "" ; sign    
        ProcedureReturn StrD(-ValD(operand1))      
        
      ElseIf type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        ProcedureReturn StrD(ValD(operand1)-ValD(operand2))
      Else
        ProcedureReturn "@"    
      EndIf        
      
    Case "+"
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        ProcedureReturn StrD(ValD(operand1)+ValD(operand2))
      Else
        ProcedureReturn "@"+operand1+operand2    
      EndIf      
      
    Case "*"
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        ProcedureReturn StrD(ValD(operand1)*ValD(operand2))
      ElseIf type1 = #DATATYPE_NUMBER
        ProcedureReturn "@"+ReplaceString(Space(Val(operand1))," ", operand2)          
      ElseIf type2 = #DATATYPE_NUMBER
        ProcedureReturn "@"+ReplaceString(Space(Val(operand2))," ", operand1)
      Else
        ProcedureReturn "@"   
      EndIf  
      
    Case "/"
      If type1 = #DATATYPE_NUMBER And type2 = #DATATYPE_NUMBER
        ProcedureReturn StrD(ValD(operand1)/ValD(operand2))     
      Else
        ProcedureReturn "@"+ReplaceString(operand1, operand2, "")   ;without operator
      EndIf    
    Default
      ProcedureReturn "@"
  EndSelect       
EndProcedure  

Procedure.s evalToken(tok.s)
  While Left(tok,1) = "#"
    ;Debug "RESOLVE:" + tok      
    last_tok.s = Right(tok, Len(tok)-1)  
    tok = token(last_tok.s)
    ;Debug "RESOLVED:" + tok
    ;     If tok = "" And last_tok = "E"
    ;       Debug "ERROR: Empty expression"
    ;     EndIf  
  Wend
  
  If Left(tok,1) = ","
    seperators.s = StringField(tok, 1, "#")
    params.s = Right(tok, Len(tok) - (Len(seperators.s) + 1)) ;also remove the first "#", so we can use the remeaing "#"'s as seperator easyly      
    
    tok = ""
    For i = 1 To Len(seperators)+1
      tok + EscapeString(prepareOperator(evalToken("#"+StringField(params, i, "#")),@type))+Chr(9) ; escape parameters and seperate by tab (chr(9))  ; avoid @'s with prepareOperator  ;IMPORTANT: unescape!!!
      If type = #DATATYPE_UNKNOWN
        evalError("invalid type3")
      EndIf  
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
  ElseIf Left(last_tok,1) = "F"  ;function or array
    function.s = StringField(tok, 1, "#")
    params.s = evalToken("#" + StringField(tok, 2, "#"))
    ;Debug "FUNCTION:" + function
    ;Debug "PARAMS:" + params
    
    If FindMapElement(arrNames(), function)
      If FindMapElement(arrsContent(), function + Chr(9) + params)
        tok = arrsContent(function + Chr(9) + params) 
      Else
        tok = "0"
      EndIf  
      
    ElseIf FindMapElement(funcs(), function)
      ;Special case of zero/one parameter. There is no ","-Operator and so prepareOperator get not called
      
      If params = ""
         ;ok to have no parameters
      ElseIf Not FindString(params, Chr(9)) 
        params = EscapeString(prepareOperator(params, @type))     
        If type = #DATATYPE_UNKNOWN
          evalError("invalid type")
        EndIf 
      EndIf
      
      ;TODO: It is not possible to distinguish between 0 and '0'!
      tok = PeekS(CallFunctionFast(funcs(function), @params))
      If tok = "" ;IMPORTANT: not allowed to return "" (e.g. msg(1)+msg(2)
        tok = "@"
      EndIf  
    Else
      evalError("function/array '" + function + "' is not implemented")
    EndIf  
  EndIf  
  
  ;Debug "RESULT:" + tok
  ProcedureReturn tok   
EndProcedure

Procedure.s evalPrepare(str.s)
  ClearMap(token())
  ClearMap(operators())   
  pos = 1
  inString = #False
  inComment = #False 
  layer_index = 0  
  line = str
  ProcedureReturn tokenize(0)  
EndProcedure

Procedure.s evalExpression(str.s)
  If str = ""
    ProcedureReturn ""
  EndIf  
  tok.s = evalPrepare(str)
  ;;DEBUGGING:  
  ;   Debug tok
  ;   Debug "======"
  ;   ForEach token()
  ;     Debug  MapKey(token()) + "    =   "  + token()    
  ;   Next 
  ;   Debug "==================="
  
  res.s = prepareOperator(evalToken(tok), @type) ;prepareOperator because of problem if expression consists only out of a constant string (@-char)
  If type = #DATATYPE_UNKNOWN
    evalError("invalid type9")
  EndIf 
  ProcedureReturn res
EndProcedure  


Procedure IsTrue(str.s)
  If str <> "" And str <> "0"
    ProcedureReturn #True  
  Else
    ProcedureReturn #False
  EndIf  
EndProcedure  

Procedure evalTrueFalse(str.s)
  tok.s = evalPrepare(str)
  ;;DEBUGGING:  
  ;   Debug tok
  ;   Debug "======"
  ;   ForEach token()
  ;     Debug  MapKey(token()) + "    =   "  + token()    
  ;   Next 
  ;   Debug "==================="
  
  ProcedureReturn IsTrue(evalToken(tok)) ;prepareOperator because of problem if expression consists only out of a constant string (@-char)
EndProcedure  

Procedure evalAssign(str.s)
  tok.s = evalPrepare(str)
  
  tokorg.s = tok
  If Left(tok,1) =  "#" 
    tok.s = Right(tok, Len(tok)-1)  
    tok = token(tok.s)
  Else
    evalError("token expected")
  EndIf
  
  ;;DEBUGGING:  
  ;     Debug tok
  ;     Debug "======"
  ;     ForEach token()
  ;       Debug  MapKey(token()) + "    =   "  + token()    
  ;     Next 
  ;     Debug "===================" 
  
  If Left(tok,2) = "=#"
    tok = Right(tok, Len(tok)-2)
    var.s = StringField(tok, 1, "#")
    exp.s = StringField(tok, 2, "#")
    
    If Left(var,1 ) = "V"
      vars(token(var)) = prepareOperator(evalToken("#"+exp), @type) ;prepareOperator because of problem if expression consists only out of a constant string (@-char)
      If type = #DATATYPE_UNKNOWN
        evalError("invalid type2")
      EndIf 
      ProcedureReturn res      
      
    ElseIf Left(var,1 ) = "F" ;Its an array
                              ;TODO:Checks
      arrayname.s = StringField(token(var), 1, "#")
      If FindMapElement(arrNames(), arrayname)
        tok.s = StringField(token(var), 2, "#")
        If tok <> ""
          result.s = evalToken("#"+exp) ;no prepareOperator here! (Strings must be saved as @...)         
          param.s = evalToken("#"+tok)  ;no prepareOperator here! already done in evalToken      
                  
          ;Debug "{" + arrayname +Chr(9) + param + "}  =   " + result
          arrsContent(arrayname + Chr(9) + param) = result
        Else
          evalError("token expected")
        EndIf
      Else
        evalError("'" + arrayname + "' is no declared array name") 
      EndIf  
    Else
      evalError("variable/array expected on left side")
    EndIf     
    
  Else
    ;evalError("assignment or function call expected")
    prepareOperator(evalToken(tokorg),@type) ;ignore result (tokorg, because function should also be executed! BUG: msg('1')+msg('2') is possible!    
    If type = #DATATYPE_UNKNOWN
      evalError("invalid type1")
    EndIf     
  EndIf  
EndProcedure



Procedure evalLine(str.s, lineNumber)
  str = Trim(str)
  cmd.s = StringField(str, 1, " ")
  exp.s = Right(str,Len(str)-(Len(cmd)+1))
  
  canExecuteDepth = execDept(Str(exec_dept))
  
  If str = ""
    ;empty line
    newLineNumber = lineNumber + 1 
    
  ElseIf Left(str,1)= "#"
    ;Commented line
    newLineNumber = lineNumber + 1 
    
  ElseIf cmd = "if"
    exec_dept + 1
    execDeptCmd(Str(exec_dept)) = "if"
    If canExecuteDepth
      execDept(Str(exec_dept)) = evalTrueFalse(exp)
    Else
      execDept(Str(exec_dept)) = #False
    EndIf       
    newLineNumber = lineNumber + 1
    
  ElseIf cmd = "else"
     If execDeptCmd(Str(exec_dept)) <> "if"
      evalError("if expected before")
    EndIf  
    If exp <> ""
       evalError("garbage after else")
     EndIf       
    
    If  execDept(Str(exec_dept-1))
      If canExecuteDepth
        execDept(Str(exec_dept)) = #False
      Else
        execDept(Str(exec_dept)) = #True
      EndIf          
    EndIf  
    
    execDeptCmd(Str(exec_dept)) = "else"
    newLineNumber = lineNumber + 1    
    
  ElseIf cmd = "endif"
    
    If exp <> ""
       evalError("garbage after endif")
     EndIf   
     
    If execDeptCmd(Str(exec_dept)) <> "if" And execDeptCmd(Str(exec_dept)) <> "else"
      evalError("if/else expected before")
    EndIf  
    
    exec_dept - 1
    newLineNumber = lineNumber + 1   
    
  ElseIf cmd = "while"
    exec_dept + 1
    execDeptCmd(Str(exec_dept)) = "while"
    
    If canExecuteDepth
      execDept(Str(exec_dept)) = evalTrueFalse(exp)
    Else
      execDept(Str(exec_dept)) = #False
    EndIf
    execGoto(Str(exec_dept)) = lineNumber    
    newLineNumber = lineNumber + 1      
    
  ElseIf cmd = "wend"
    
    If execDeptCmd(Str(exec_dept)) <> "while"
      evalError("while expected before")
    EndIf  
    If exp <> ""
       evalError("garbage after wend")
    EndIf    
    
    If canExecuteDepth
      newLineNumber = execGoto(Str(exec_dept))
      ;Debug "Goto line " + newLineNumber
    Else
      newLineNumber = lineNumber + 1 
    EndIf  
    exec_dept - 1
  ElseIf cmd = "end"
    If canExecuteDepth    
      If exp <> ""
        evalError("garbage after end")
      EndIf
      newLineNumber = -1
    Else
    newLineNumber = lineNumber + 1      
    EndIf
    
  ElseIf cmd = "syntaxoff"
    syntaxcheck = #False
    newLineNumber = lineNumber + 1
    
  ElseIf cmd = "syntaxon"
    syntaxcheck = #True
    If exp <> ""
      evalError("garbage after syntaxon")
    EndIf   
    newLineNumber = lineNumber + 1
    
  ElseIf cmd = "halt"
    If exp <> ""
      evalError("garbage after halt")
    EndIf   
    newLineNumber = lineNumber ;do not increase newLineNumber here  
    
  ElseIf cmd = "dim"
    If canExecuteDepth
      If isValidVariable(exp)
        arrNames(exp) = #True
      Else
        evalError("'" + exp +  "' is not a valid variable name")
      EndIf  
    EndIf
    newLineNumber = lineNumber + 1
  Else
    If canExecuteDepth
      evalAssign(str)
    EndIf  
    newLineNumber = lineNumber + 1   
  EndIf  
  ProcedureReturn newLineNumber
EndProcedure

;binOr,binAnd,hex,...


Procedure.s my_eval(params)
  ProcedureReturn evalExpression(StringField(PeekS(params),1,Chr(9)))
EndProcedure

Procedure.s my_assign(params)
  evalAssign(StringField(PeekS(params),1,Chr(9)))
  ProcedureReturn ""
EndProcedure  
  
Procedure.s my_cos(params)
  ProcedureReturn StrD(Cos(ValD(StringField(PeekS(params),1,Chr(9)))))
EndProcedure  

Procedure.s my_sin(params)
  ProcedureReturn StrD(Sin(ValD(StringField(PeekS(params),1,Chr(9)))))
EndProcedure  

Procedure.s my_msg(params)
  title.s = UnescapeString(StringField(PeekS(params),1,Chr(9)))
  text.s = UnescapeString(StringField(PeekS(params),2,Chr(9))) 
  MessageRequester(title.s, text.s)
  ProcedureReturn "" 
EndProcedure

Procedure.s my_question(params)
  title.s = UnescapeString(StringField(PeekS(params),1,Chr(9)))
  text.s = UnescapeString(StringField(PeekS(params),2,Chr(9)))
  If MessageRequester(title.s, text.s, #PB_MessageRequester_YesNo) =  #PB_MessageRequester_Yes    
    ProcedureReturn "1" 
  Else
    ProcedureReturn "0"     
  EndIf  
EndProcedure

Procedure.s my_filewrite(params)
  file.s = UnescapeString(StringField(PeekS(params),1,Chr(9)))
  content.s = UnescapeString(StringField(PeekS(params),2,Chr(9)))

  CreateFile(1,file)
  WriteStringN(1, content)
  CloseFile(1)
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
funcs("eval") = @my_eval()
funcs("assign") = @my_assign()
funcs("question") = @my_question()
funcs("filewrite") = @my_filewrite()

arrNames("a") = #True

;Debug evalAssign("hi=9")
;Debug evalAssign("hi='u9'")
Debug vars("hi")
Debug "---"
Debug "result:" + evalExpression("assign('hello=2')")
Debug "result:" + evalExpression("hello")
End

;arrNames("a") = #True

;evalAssign("a()=7.5")
;evalAssign("msg(a())+msg('hi')")
;evalAssign("msg('a'+'b')|msg('hi','too')")

Dim lines.s(100)
lines(0) = "dim f"
lines(1) = "f(0) = 1"
lines(2) = "f(1) = 2"
lines(3) = "while A<10"
lines(4) = "A=A+1"
lines(5) = "if A>6"
lines(6) = "else"
lines(7) = "if question(A,'beenden?')"
lines(8) = "filewrite('F:\test.txt', 'HELLO WORLD')"
lines(9) = ""
lines(10) = "else"
lines(11) = "msg('foo')"
lines(12) = "endif"
lines(13) = "endif"
lines(14) = "wend"
lines(15) = "end"

execDept("0") = #True
Repeat

  currentline = evalLine(lines(currentline), currentline)
  Debug vars("A")
  
  ;Debug "line " + Str(currentline)
Until currentline > 14 Or currentline=-1

; Debug tokenize(0)
; 

