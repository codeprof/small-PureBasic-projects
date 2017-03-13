;================================================================================================================================
;SUBJECT: A small snippet to generate different types of passwords
;AUTHOR:  codeprof
;LICENSE: PUBLIC DOMAIN (can be used without any restriction)
;         This software is provided 'as-is', without any express or implied warranty.
;         In the author cannot be held liable for any damages arising from the use of this software.
;         Use this software at your own risk. 
;DATE:    2013-03-10
;================================================================================================================================
Procedure.s GenerateReadablePassword(length.i = 6)
  Protected i, password.s = ""  
  vocs.s = "aeiou"
  cons.s = "bcdfghjklmnpqrstvwxyz"
  If OpenCryptRandom()  
  For i = 0 To length-1
    If i & 1
      password.s + Mid(vocs, CryptRandom(Len(vocs) - 1) + 1, 1) 
    Else
      password.s + Mid(cons, CryptRandom(Len(cons) - 1) + 1, 1)       
    EndIf  
  Next
   CloseCryptRandom()  
  EndIf  
  ProcedureReturn password
EndProcedure

Procedure.s GenerateRandomPassword(length.i = 30, allowedChars.s = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$&§!?%*+-_")
  Protected i, password.s = ""
  If OpenCryptRandom()
    For i = 0 To length - 1
      password.s + Mid(allowedChars, CryptRandom(Len(allowedChars) - 1) + 1, 1)
    Next
    CloseCryptRandom()
  EndIf
  ProcedureReturn password
EndProcedure  

Procedure.s GeneratePassphrasePassword(length.i = 25, allowedSpecialChars.s = "$&§!?%*+-_")
  Protected password.s = ""  
  While (Len(password) < length)
    password + GenerateReadablePassword(4) + " " 
    password + GenerateRandomPassword(4, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" + allowedSpecialChars) + " "  
  Wend  
  
  password = Trim(Left(password, length))
  allowedSpecialChars = ReplaceString(allowedSpecialChars, " ", "")
  password + GenerateRandomPassword(length - Len(password), "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" + allowedSpecialChars)
  ProcedureReturn password
EndProcedure  


For t=0 To 24
  Debug GenerateReadablePassword()
Next

For t=0 To 24
  Debug GenerateRandomPassword()
Next

For t = 0 To 24
  Debug GeneratePassphrasePassword()
Next 
