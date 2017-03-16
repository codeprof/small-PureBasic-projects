

;#E: Empty
;#V: possible Variable
;#N: Number
;#F: Function/Array
;#S: String constant
Global pos = 1


Global line.s = "2*(5*4)+2";"1*(8*A)=2+(4*E)" ; ".4+4*(6+(i)+(i6)+(-k)+(kg*(p+q-hooo))+6)+'hey(y+o)h'";4+(66*(21+55*A+B-C(a,b,c)))*9"
Global inString
Global inComment
Global layer_index = 0
Global NewMap token.s()
Global NewMap operators.s()
Global NewMap vars.s()
Global NewMap funcs.i()

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
     Debug "ERROR: operand is missing" 
  ElseIf FindString(str, " ")
    Debug "ERROR: operator is missing"
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
        Debug "ERROR: invalid operand" ; don't show internals
      Else  
        Debug "ERROR: invalid operand '" + str + "'"
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

Procedure.s ApplyOperators(str.s)
  str = ApplyOperator(str.s, "/")
  str = ApplyOperator(str.s, "*") 
  str = ApplyOperator(str.s, "-") 
  str = ApplyOperator(str.s, "+")  
  str = ApplyOperator(str.s, "=")     
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
    If FindString(",=-+*/", ch)
      tmp = Trim(tmp)
      If tmp.s <> "" 
        res + analyzeOperand(tmp)       
        tmp = ""
        ;res + ch ;# can be used as seperator here
        ops + ch   ;Add operators to another list
        signadded = #False
      Else
        If ch <> "-" ;allow sign
          Debug "ERROR:left operand missing"
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
    Debug "ERROR:right operand missing"
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
      token(Str(layer)) = ApplyOperators(splitOperators(coll))
      If layer = 0
        Debug "ERROR: bracked was not opened before" 
      Else
        ProcedureReturn "#" + Str(layer)    
      EndIf
      
    ElseIf ch = "'" And Not inComment  
      inString = ~inString
      If inString
        layer_index+1
        coll + tokenize(layer_index)
      Else
        token("S"+Str(layer)) = coll      
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
    Debug "ERROR: bracked not closed"
  Else  
    ProcedureReturn ApplyOperators(splitOperators(coll))
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

Procedure.s evalOperator(operators.s, operand1.s, operand2.s)
  Debug "OP:" + operators.s +" " + operand1.s + " "+ operand2.s
  operand1 = simplifySigns(operand1)
  operand2 = simplifySigns(operand2)  
Select operators.s
    
    
  Case "="
    If operand1 = operand2
      ProcedureReturn "1"
    Else
      ProcedureReturn "0"
    EndIf  
  Case "-"      
    If isValidNumber(operand1,#True) And operand2 = ""
      
      Debug "U:" + StrD(-ValD(operand1)) 
      Debug ValD(operand1)
      ProcedureReturn StrD(-ValD(operand1))      
      
    ElseIf isValidNumber(operand1,#True) And isValidNumber(operand2,#True)
      ProcedureReturn StrD(ValD(operand1)-ValD(operand2))
    Else
      ProcedureReturn ""    
    EndIf        
    
  Case "+"
    If isValidNumber(operand1,#True) And isValidNumber(operand2,#True)
      ProcedureReturn StrD(ValD(operand1)+ValD(operand2))
    Else
      ProcedureReturn operand1+operand2    
    EndIf      
    
  Case "*"
    If isValidNumber(operand1,#True) And isValidNumber(operand2,#True)
      ProcedureReturn StrD(ValD(operand1)*ValD(operand2))
    ElseIf isValidNumber(operand1,#False)
      ProcedureReturn ReplaceString(Space(Val(operand1))," ", operand2)          
    ElseIf isValidNumber(operand2,#False)
      ProcedureReturn ReplaceString(Space(Val(operand2))," ", operand1)
    Else
      ProcedureReturn ""   
    EndIf  
    
  Case "/"
    If isValidNumber(operand1,#True) And isValidNumber(operand2,#True)
      ProcedureReturn StrD(ValD(operand1)/ValD(operand2))
    Else
      ProcedureReturn ""   
    EndIf    
  Default
    ProcedureReturn ""
  EndSelect       
EndProcedure  


 

Procedure.s evalToken(tok.s)
  While Left(tok,1) = "#"
    ;Debug "RESOLV:" + tok      
    last_tok.s = Right(tok, Len(tok)-1)  
    tok = token(last_tok.s)
    ;Debug "RESOLVED:" + tok
  Wend
  
  If Left(tok,1) = ","
    seperators.s = StringField(tok, 1, "#")
    params.s = Right(tok, Len(tok) - (Len(seperators.s) + 1)) ;also remove the first "#", so we can use the remeaing "#"'s as seperator easyly      
    
    tok = ""
    For i = 1 To Len(seperators)+1
      tok + EscapeString(evalToken("#"+StringField(params, i, "#")))+Chr(9) ; ecape parameters and seperate by tab (chr(9))
    Next  
    
  ElseIf FindString("=-+*/", Left(tok,1))
     
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
    tok = vars(tok)    
  ElseIf Left(last_tok,1) = "F"  
    function.s = StringField(tok, 1, "#")
    params.s = evalToken("#" + StringField(tok, 2, "#"))
    Debug "FUNCTION:" + function
    Debug "PARAMS:" + params
    If FindMapElement(funcs(), function)
      tok = PeekS(CallFunctionFast(funcs(function), @params))
    Else
      Debug "ERROR: function '" + function + "' is not implemented"
    EndIf  
  EndIf  
  
  Debug "RESULT:" + tok
  ProcedureReturn tok   
EndProcedure


Procedure.s eval(str.s)
  line = str
  tok.s = tokenize(0)
  
    Debug tok
    Debug "======"
    ForEach token()
      Debug  MapKey(token()) + "    =   "  + token()    
    Next 
   Debug "==================="
  
  ProcedureReturn evalToken(tok)
EndProcedure  

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


vars("a")= "1000.5"
vars("b")= "5"
vars("c5")="test"
funcs("cos") = @my_cos()
funcs("sin") = @my_sin()
funcs("msg") = @my_msg()

Debug eval("'AB'='A'+'B'")



; Debug tokenize(0)
; 



