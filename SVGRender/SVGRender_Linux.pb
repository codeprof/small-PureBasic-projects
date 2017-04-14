ImportC ""
  gdk_pixbuf_get_width (*pixbuf)
  gdk_pixbuf_get_height (*pixbuf)
	gdk_pixbuf_loader_write(*loader, *buf, count, *error)
	gdk_pixbuf_loader_get_pixbuf(*loader)
	gdk_pixbuf_loader_new()
	gdk_pixbuf_loader_close(*loader, *error)
EndImport

#GTK_IMAGE = 100

Procedure __LoadPixbuf(*mem, size)
	Protected ok = #True
	Protected *loader = gdk_pixbuf_loader_new()
	Protected *pixbuf = #Null, *err.GError = #Null

	If *mem = #Null
	  ok = #False
	  Debug "LoadPixbuf called with invalid mem argument"
	EndIf  
	
	If ok
  	If size < 1
  	  ok = #False
  	  Debug "LoadPixbuf called with invalid size argument"
  	EndIf  	  
	EndIf  
	
	If ok
	  gdk_pixbuf_loader_write(loader, *mem, size, @*err)
	  If *err	  
	    ok = #False
		  Debug "gdk_pixbuf_loader_write failed with error: " + PeekS(*err\message, -1, #PB_UTF8)
		EndIf
 EndIf		
 
 If ok
		*err = #Null
		gdk_pixbuf_loader_close(loader, @*err)	
		If *err	  
		  ok = #False
		  Debug "gdk_pixbuf_loader_close failed with error: " + PeekS(*err\message, -1, #PB_UTF8)
		EndIf	
	EndIf
	
	If ok
  *pixbuf = gdk_pixbuf_loader_get_pixbuf(loader)	
	EndIf
	ProcedureReturn *pixbuf
EndProcedure


Procedure SVG_Init()
  ProcedureReturn #True
EndProcedure  

Procedure SVG_Free()
  ProcedureReturn #True
EndProcedure

Procedure SVG_Render(width, height, resizeWidth, resizeHeight, *mem, size)
  Protected img, width, height
  img = __LoadPixbuf(*mem,size)
  
  If img
    width = gdk_pixbuf_get_width (img)
    height = gdk_pixbuf_get_height (img)
    
    If IsImage(#GTK_IMAGE) And ImageWidth(#GTK_IMAGE) = width And ImageHeight(#GTK_IMAGE) = height
      CreateImage(#GTK_IMAGE, width, height, 32)
    EndIf  
    StartDrawing(ImageOutput(#GTK_IMAGE))  
    DrawingMode(#PB_2DDrawing_AllChannels)
    DrawImage(img, 0, 0)
    StopDrawing()
    ResizeImage(#GTK_IMAGE,resizeWidth, resizeHeight)  
  EndIf
EndProcedure

