;================================================================================================================================
;SUBJECT: Generating random numbers with a string as seed
;         This should fill the gap between Random() and CryptRandom()
;AUTHOR:  codeprof
;LICENSE: PUBLIC DOMAIN (can be used without any restriction)
;         This software is provided 'as-is', without any express or implied warranty.
;         In the author cannot be held liable for any damages arising from the use of this software.
;         Use this software at your own risk.
;DATE:    2013-03-23
;================================================================================================================================

;Advantages:
; - String can be used as seed!
; - more secure than Random()
; - configurable whether it should be fast or more secure
; - supports Unicode (and returns the same values like in ANSI mode)
; - support for quad random numbers (up to 63 bits instead of 31 bits with Random())
; - works for Windows, Linux and MacOSX

;Disadvantages:
; - probably not as secure as CryptRandom()
; - not thread safe  ( as the "Threaded" keyword of PureBasic cannot be used inside procedures
;                      To make it thread safe move the "Static" variables outside of the procedure as
;                      global variables and use the "Threaded" keyword)



;================================================================================================================================
;Initializes the random number generator with an seed string.
;Parameters:
; seed                      : string with which the random number generator is initialized (max 128 chars)
; num_iterations [optional] : Number of times the result should be hashed with MD5
;                             The result should be at least hashed once for security reason (prevents known plaintext attacks...)
;                             If security is not important "num_iterations" can be set to 0 to improve performace.
;                             A high number will result in very slow number generation.
;                             This could be used to prevent timing attacks (make brute force attacks harder).
;================================================================================================================================
Procedure.q QRandomSeed(seed.s, num_iterations.i = 1)
  Static Dim key.q(1)
  Static Dim current.q(1)   
  Static Dim tmp.q(1)
  Static num_md5_iterations = 0
  Protected md5.s, i.i
  If seed <> ""
    ;Initalize random number generator
    Protected Dim seed_string.UNICODE(127 + 1)
    PokeS(@seed_string(0), Left(seed,128), 128, #PB_Unicode)   
    ;We use the MD5 of "seed.s" to generate a 128 bit key.
    md5.s = MD5Fingerprint(@seed_string(0), SizeOf(UNICODE) * 128)     
    key(0) = Val("$" + Left(md5, 16))
    key(1) = Val("$" + Right(md5, 16))   
    ;The MD5 of the MD5 is used here so it is not possible to restore the key out of it (as reverting the MD5 is not possible).
    ;MD5(seed)+seed is used to reduce the chance for a collision, because it is much harder to find a string
    ;which returns a correct result for MD5(seed) and MD5(MD5(seed)+seed).
    PokeS(@seed_string(0), Left(md5 + seed, 128), 128, #PB_Unicode)      
    md5.s = MD5Fingerprint(@seed_string(0), SizeOf(UNICODE) * 128)      
    current(0) = Val("$" + Left(md5, 16))
    current(1) = Val("$" + Right(md5, 16))
    num_md5_iterations = num_iterations
  Else
    ;generate the next random number
    AESEncoder(@current(0), @tmp(0), 128 / 8, @key(0), 128, #Null, #PB_Cipher_ECB)
    CopyMemory(@tmp(0), @current(0), 128 / 8)     
    ;To prevent short cycles we increment the 128 bit key by 1.
    key(0) + 1
    If key(0) = 0:key(1) + 1:EndIf
    ;hash the result with MD5
    For i = 1 To num_md5_iterations
      md5.s = MD5Fingerprint(@tmp(0), 16)     
      tmp(0) = Val("$" + Left(md5, 16))
      tmp(1) = Val("$" + Right(md5, 16))     
    Next 
  EndIf 
  ProcedureReturn tmp(0) ! tmp(1)   
EndProcedure 


;================================================================================================================================
;Random number between "min" and "max" (including "min" and "max")
;The functions supports random numbers up to 63 bits.
; max                       : maximum number (must be greater than "min")
; min                       : minimum number (must be less than "max")
;================================================================================================================================
Procedure.q QRandom(max.q, min.q = 0)
  Protected val.q = QRandomSeed("") & $7FFFFFFFFFFFFFFF
  val = val % ( max - min + 1)
  ProcedureReturn val + min
EndProcedure 







;Example

QRandomSeed("MY TOP SECRET MASTER PASSWORD", 100)
For j = 1 To 10
 
  passwd$ = ""
  For i = 0 To 30
    passwd$ + Chr(QRandom(126,33))
  Next 
 
  Debug "Password("+Str(j)+"): " + passwd$
Next   
