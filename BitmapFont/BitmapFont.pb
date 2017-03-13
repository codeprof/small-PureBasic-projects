;=========================================
;Bitmap Font Sample version 1 (2013-03-05)
;=========================================
;Licence: Public domian

#BITMAPFONT_WIDTH = 9
#BITMAPFONT_HEIGHT = 13

Global Dim _g_bitmapfont_images(255)
Global _g_bitmapfont_color, _g_bitmapfont_bkcolor

Procedure __BitmapFontFilterCB(x, y, src, dst)
  ;Colors are eigher $FFFFFFFF or $00000000 in our Bitmap, so the result of "src & _g_bitmapfont_color" is either _g_bitmapfont_color or $00000000
  ProcedureReturn AlphaBlend(src & _g_bitmapfont_color, AlphaBlend(_g_bitmapfont_bkcolor, dst))
EndProcedure

;Frees all resources reserved by LoadBitmapFont()
Procedure FreeBitmapFont()
  For i = 0 To 255
    If IsImage(_g_bitmapfont_images(i))
      FreeImage(_g_bitmapfont_images(i))
      _g_bitmapfont_images(i) = #Null
    EndIf  
  Next  
EndProcedure

;Loads the image for 256 chars out of a big image containing all chars
Procedure LoadBitmapFont()
  Protected image, ch, result = #True
  UsePNGImageDecoder()
  image = CatchImage(#PB_Any, ?Bitmap_Font) 
  If IsImage(image)
    For ch = 0 To 255
      ;Grab the images from a 16x16 grid
      _g_bitmapfont_images(ch) = GrabImage(image, #PB_Any, (ch & 15) * #BITMAPFONT_WIDTH, (ch >> 4) * #BITMAPFONT_HEIGHT, #BITMAPFONT_WIDTH, #BITMAPFONT_HEIGHT)  
      If Not IsImage(_g_bitmapfont_images(ch))  
        result = #False
      EndIf  
    Next  
    FreeImage(image)
  Else
    result = #False
  EndIf  
  
  If result = #False 
    ; Free all resources if something failed
    FreeBitmapFont()
  EndIf  
  ProcedureReturn result
EndProcedure

;Draws the declared string at x,y with the declared color.
;Optionally a background color is possible. Half transparent colors are also supported
Procedure DrawBitmapText(string.s, x, y, color, bkcolor = $00000000)
  Protected i, ch
  DrawingMode(#PB_2DDrawing_CustomFilter)
  CustomFilterCallback(@__BitmapFontFilterCB())
  _g_bitmapfont_color = color
  _g_bitmapfont_bkcolor = bkcolor
  For i = 1 To Len(string)
    ch = Asc(Mid(string, i, 1))
    If ch < 0 Or ch > 255:ch = 255:EndIf
     DrawImage(ImageID(_g_bitmapfont_images(ch)), x, y)      
    x + #BITMAPFONT_WIDTH
  Next  
  DrawingMode(#PB_2DDrawing_Default)
EndProcedure  

DataSection
  Bitmap_Font:
  Data.q $A1A0A0D474E5089,$524448490D000000,$D000000090000000,$7AD0D20000000301,$544C500600000097,$A5FFFFFF00000045,$7401000000DD9FD9
  Data.q $66D8E64000534E52,$5441444940060000,$D71C6841D6CD5E78,$53789E4FFF00719,$25376522CE3A359E,$2DA45336F0081890,$392F494B53DD7791
  Data.q $164036065BCA50B5,$2986795452CB9322,$9CE024575D1ACBAB,$DF8301260A1C63D2,$38C82DF50CBA3030,$18C6531744A8B3C4,$2B46F7BEA4590992
  Data.q $A7FE4BEAB5B4DE59,$61BCDEFA7DEFA7E1,$4AA393A0E39A7076,$709640E0E8CC11A7,$9BE38148095DEE81,$EAE05DA3CA237C5C,$1FBBE38179864CDD
  Data.q $3BC0C7A65113FCFF,$3F883949E24E1FB7,$AE9EAAA9AFABDBFB,$7C1A74C3F870787A,$F804A3CA4427E9FC,$69F455DF8787ADD3,$F0F17F6F453DC818
  Data.q $20711BE166FBDBF0,$A14B925EF0BD43D3,$A5BD7C9077B1BFDB,$3B78FD10D5942F69,$B8F442351E81E8F9,$FDDA3851861EA3D4,$458AF07CD3CD0DD1
  Data.q $1388CD97700AB499,$AAB3AC18B83F2587,$41F4A31BB2D08E4,$3BAD1496B2696E98,$59090BD73F7A594,$80F450DDA26C6EE2,$AE9154F60B86B26B
  Data.q $CB7127FBDC6A2A4A,$A9D307FB8145EA96,$11A4E2292F1FB2AE,$210EDC0E983FF60,$D7E4C3973525D358,$328022A075BB94DE,$9E478B885A8720F9
  Data.q $7B29C039C61B5607,$F239E8CE0D8E129A,$73B4D1034B26BED8,$6A14B92E17DE3DB0,$25C06F84E3408AA2,$45722E648662A9B6,$E5B76AE129397B8D
  Data.q $E726B8AB4FB7C46,$984BD568C077BB9A,$91608AC65778985,$F411EE37F1434B90,$A7F3C510D99E9AA8,$DD56D6CB7648ED4E,$1262A59D5E1D60A9
  Data.q $46B0F50C0B579E88,$435040486A491521,$40AC8B5799206EDD,$A2DDC615A8745382,$6F0CBA5861457564,$8139EB99B85F0251,$64D0BF0A22AE57B9
  Data.q $8FF831141554B005,$A3C2EE0904D719C7,$4040AC4226AE8A8C,$31459127637A8B8,$7536962F04245F5E,$EA453EEBA72E24A2,$AFA961DF05A8DA93
  Data.q $7E1F518BE8ABD436,$129AA640CDF9946D,$9144457DE2967DF2,$59A446769A47A13C,$987F222F629D7948,$4E774672AA986A2A,$7DAC2D4CA7C3FE49
  Data.q $B14A3437B59C4294,$3EAE666086CD1B55,$D4FB6CAA3D1DB53A,$385FFFA8F44FFA1E,$AF522D56DB545ED0,$CCB7800628913376,$67819F930A189152
  Data.q $A381844519A39A8A,$CDDA86A22BAA6822,$1884A1CC97D3489D,$62528860611BCDE2,$8CA754D48142705,$69EFAAFFB4CF21A4,$722A5B914C1A8612
  Data.q $62E3225844315E09,$58002A3D0D39EFA3,$3B8BE78C758E9E01,$C3599C0B40A34C4F,$99FFA01C02435F59,$BAE6E514993B0DEA,$E75013628A89385A
  Data.q $A38A2AAD915DF3D4,$7EA236A340A7EFDF,$6784D3C8AC3B6869,$7535362F69A17E68,$1BB9E46CF37F7723,$B00DBBCF3CE00180,$FD7A4089E7A49CA4
  Data.q $91CD6CDE94E0AC0A,$3BB264EDA5C6ED39,$2E90A66EB7FD4A,$72EAD150DD4673CF,$D158ED1686E4822D,$1BA188CC84CB2B97,$B119E9165737F78E
  Data.q $2591757372E367EE,$D971B17996CCF6B3,$3827001CCA588DA7,$6D3C5D19D0D98AC9,$91750DDAD0E6DB38,$3992840BD2C9FCA3,$4FE3537ED73ED462
  Data.q $9220A006F31E2E95,$B44D0068639E8E70,$FE9ADB4B1B79CCB7,$D787BCE13C946D0A,$9439359FD600157F,$BF4D6BFCB8179C78,$1F7CE66921B545D5
  Data.q $55D1377DAD177F97,$D555F40AF1275D4,$C90A4A218EF592C5,$B66972655FAF157,$5551DA58EBC172E9,$7067920187523FE6,$CD15C9D45CC9F840
  Data.q $7D60024245C7329F,$F5006014D690DA81,$30AC705BD173296,$1CDBBE2C6C5607D2,$34052EC4D004226B,$FAC0AD0CEBD00511,$86D0B3724A3B22B0
  Data.q $B5C9468A5A8FBB5,$7DC6B003DAAE2BE,$7004776B93DED360,$E115F72F6E572046,$EB3378BF7BE19C94,$292C09A151409D01,$BB57E93AF67D74C4
  Data.q $9C6D7FE404AB25E4,$A0402E6E5616C713,$7373EA46ED6977A7,$F084C19C78838A31,$30AC4A32E34E01CD,$A40E27634EADB22F,$6E4F14763BAF58E0
  Data.q $FA79EA1A8B7F4265,$EA54D1CE4B79B6C7,$3C1DEC5BA4343327,$CEE839EBD52A91FE,$79AFF8E4B310D9C6,$D897003EF1456479,$FEA128D60C002143
  Data.q $39484994665E31B5,$99015006DDECFF40,$BC0BCC7B51DCD7A1,$EAEE5FA2A5E1A66B,$B7C32CA2AF78C621,$5ADE8FB4674A2A57,$BD0B533CDD437D45
  Data.q $93FB752C84865A8A,$9427FA19922A0FAA,$1FC43660C4A84FB6,$E3E0BC0A52971DF5,$5E77FD884B81AE7E,$D183EF040DDA0B98,$290045F404391B85
  Data.q $8924003F40F9837F,$4D3EA473BF5B69F3,$76AFAAF821146FE8,$A4C1D18FEA430990,$9AE5EF373BD71238,$3E8568EA7B0E39F4,$DD3E17E7B74D3C5A
  Data.q $E982E0ACB986167E,$2B300651F8C853D4,$AC8B5B03D97388C,$855D2F215AF355F,$DA4451DEF99FB409,$CFBCA4FA3A0C2FD5,$C3F4CDD96742FFA7
  Data.q $F747DA56F3535F09,$45FC239FDF8E8AC3,$A53B5D19D6D3CF13,$FA3BAF77B4C7674E,$C0D8EEFF9DD4C5D4,$15C4E8B637F891B3,$364C4CC1,$826042AE444E4549
EndDataSection


  

;Example

CompilerIf Not Defined(Cyan, #PB_Constant)
  #Cyan = 16776960
CompilerEndIf

LoadBitmapFont()

RandomSeed(19)
OpenWindow(0, 0, 0, 800, 800, "Bitmap Font Example", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CreateImage(0, 800, 800)
StartDrawing(ImageOutput(0))

Box(0, 0, 400, 400, #Cyan)

DrawBitmapText("Transparent Text", 5,  5, RGBA(255,0,0,255))
DrawBitmapText("With Background",  5, 25, RGBA(0,255,0,255), RGBA(255,0,255,255))

For i = 1 To 30
  DrawBitmapText("PureBasic is cool" + Chr(3) + Chr(3) + Chr(3), Random(800), Random(800), RGBA(Random(255), Random(255), Random(255), Random(255) ) )
Next i

StopDrawing() 
ImageGadget(0, 0, 0, 200, 200, ImageID(0))

Repeat
  Event = WaitWindowEvent()
Until Event = #PB_Event_CloseWindow