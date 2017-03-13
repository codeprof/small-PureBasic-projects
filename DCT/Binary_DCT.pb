Global Dim Binary_DCT_Lookup.f($FF, 7)

Procedure fillLookup()
  
  For binary_value = 0 To 255   
    For x=0 To 7
      res.f = 0.0
      For x2 = 0 To 7
        If (binary_value & (1 << x2))
          res + Cos(#PI * (x) * (2 * (x2) + 1.0)/ (8.0 * 2.0))
        EndIf  
      Next
      Binary_DCT_Lookup(binary_value, x) = res
    Next
  Next  
EndProcedure  

fillLookup()
NUM = %10101010
For x=0 To 7
  Debug Binary_DCT_Lookup(NUM, x)
Next  
