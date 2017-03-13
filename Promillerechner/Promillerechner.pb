
;Promillerechner v1.0 (18 Juli 04)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enumeration
  #Panel_0
  #Spin_0
  #Spin_1
  #Spin_2
  #Spin_3
  #Spin_4
  #Text_0
  #Text_1
  #Text_2
  #Text_3
  #Text_4
  #Text_5
  #Text_6
  #Text_7
  #Text_8
  #Text_9
  #Text_10
  #Text_11
  #Text_12
  #Text_13
  #Radio_0
  #Radio_1
  #Button_0
  #Button_1
EndEnumeration




OpenWindow(1,0,0,280,150,#PB_Window_SystemMenu|#PB_Window_ScreenCentered,"Stefan's Promillerechner v1.0")
    SetWindowPos_(WindowID(),#HWND_TOPMOST,0,0,0,0,#SWP_NOSIZE|#SWP_NOMOVE)
    
    Font=LoadFont(1,"Webdings",56)
    Icon=LoadIcon_(0,100)
    AddSysTrayIcon(0,WindowID(),Icon) 
    SendMessage_(WindowID(),#WM_SETICON,0,Icon)
    
    CreateGadgetList(WindowID())
      ButtonGadget(#Button_0, 0, 130, 90, 20, "Berechnen")
      ButtonGadget(#Button_1,90, 130, 40, 20, "Info")
      
      PanelGadget(#Panel_0  ,   0,  0, 280, 130)
      AddGadgetItem(#Panel_0,  -1,  "Konsum")
      
      TextGadget(#Text_12   , 180,  2,  90, 90,Chr($E5))
            
      TextGadget(#Text_0    ,   8,  8,  70, 20, "Bier (5%):")
      SpinGadget(#Spin_0    ,  88,  8,  50, 20, 0, 250)
      TextGadget(#Text_1    , 148,  8,  30, 20, "Liter")
      TextGadget(#Text_2    ,   8, 28,  70, 20, "Wein (14%):")
      SpinGadget(#Spin_1    ,  88, 28,  50, 20, 0, 250)
      TextGadget(#Text_3    , 148, 28,  30, 20, "Liter")
      TextGadget(#Text_10   ,   8, 48,  70, 20, "Whisky (43%):")
      SpinGadget(#Spin_4    ,  88, 48,  50, 20, 0, 250)
      TextGadget(#Text_11   , 148, 48,  30, 20, "Liter")
      
      AddGadgetItem(#Panel_0,  -1, "Einstellungen")
      TextGadget(#Text_4    ,   8, 10,  50, 20, "Gewicht:")
      SpinGadget(#Spin_2    ,  58,  8,  50, 20, 1, 250)
      
      TextGadget(#Text_6    , 115, 10,  50, 20,"kg")
      TextGadget(#Text_7    ,   5, 30, 100, 20,"Geschlecht:")
      TextGadget(#Text_8    ,   5, 82, 100, 20,"Zeitraum:")
      SpinGadget(#Spin_3    ,  58, 80,  50, 20, 1,24)
      TextGadget(#Text_9    , 115, 82,  50, 20,"Stunde(n)")
      
      OptionGadget(#Radio_0 ,   8, 48,  40, 20,Chr(11))
      OptionGadget(#Radio_1 ,  48, 48,  40, 20,Chr(12))    
      
      TextGadget(#Text_13   , 180,  2,  90, 90,Chr($82))
      
      SetGadgetFont(#Text_12,Font)
      SetGadgetFont(#Text_13,Font)
      SetGadgetFont(#Radio_0,GetStockObject_(#OEM_FIXED_FONT))
      SetGadgetFont(#Radio_1,GetStockObject_(#OEM_FIXED_FONT))
      SetGadgetFont(#Button_0,GetStockObject_(#SYSTEM_FIXED_FONT))
      SetGadgetFont(#Button_1,GetStockObject_(#SYSTEM_FIXED_FONT))
      SetGadgetState(#Radio_0,1)
      SetGadgetText(#Spin_0,"0.0")
      SetGadgetText(#Spin_1,"0.0")
      SetGadgetText(#Spin_4,"0.0")
      SetGadgetText(#Spin_2,"85")
      SetGadgetState(#Spin_2,85)
      SetGadgetText(#Spin_3,"1")
      SetGadgetState(#Spin_3,1)
      
      CloseGadgetList()



Repeat
  Event=WaitWindowEvent()
  
  If Event=#PB_EventSysTray 
  If EventType()=#PB_EventType_LeftClick:Show=~Show:HideWindow(1,Show):EndIf
  EndIf
   
  If Event=#PB_Event_Gadget 
    
    Select EventGadgetID()
      
      Case #Spin_0
        Text$=Str(GetGadgetState(#Spin_0))
        T$=Left(Text$,Len(Text$)-1)+"."+Right(Text$,1)
        If Len(Text$)=1:T$="0"+T$:EndIf
        SetGadgetText(#Spin_0,T$) 
        WindowEvent()
        
      Case #Spin_1
        Text$=Str(GetGadgetState(#Spin_1))
        T$=Left(Text$,Len(Text$)-1)+"."+Right(Text$,1)
        If Len(Text$)=1:T$="0"+T$:EndIf
        SetGadgetText(#Spin_1,T$) 
        WindowEvent() 
        
      Case #Spin_4
        Text$=Str(GetGadgetState(#Spin_4))
        T$=Left(Text$,Len(Text$)-1)+"."+Right(Text$,1)
        If Len(Text$)=1:T$="0"+T$:EndIf
        SetGadgetText(#Spin_4,T$) 
        WindowEvent() 
        
      Case #Spin_2
        SetGadgetText(#Spin_2,Str(GetGadgetState(#Spin_2))) 
        WindowEvent()
        
      Case #Spin_3
        SetGadgetText(#Spin_3,Str(GetGadgetState(#Spin_3))) 
        WindowEvent()
        
      Case #Button_0
        
        Bier.f=ValF(GetGadgetText(#Spin_0))
        Wein.f=ValF(GetGadgetText(#Spin_1))
        Whisky.f=ValF(GetGadgetText(#Spin_4))
        Gewicht.f=ValF(GetGadgetText(#Spin_2))
        Zeit.f=ValF(GetGadgetText(#Spin_3))
        
        Geschl=0
        If GetGadgetState(#Radio_1):Geschl=1:EndIf 
        
        Select Geschl
          Case 0;Weiblich
            Erg.f=((Bier*0.05+Wein*0.14+Whisky*0.43)*1000*0.785)/(Gewicht*0.73)-(0.15*Zeit)
          Case 1;Männlich
            Erg.f=((Bier*0.05+Wein*0.14+Whisky*0.43)*1000*0.785)/(Gewicht*0.66)-(0.1*Zeit)
        EndSelect
        
        If Erg<0:Erg=0:EndIf
        Result$=StrF(Erg,4)
        MessageRequester("Promillerechner","Promille: "+Result$+" ‰ .",#MB_ICONINFORMATION)
        
      Case #Button_1
        
        Text$="Promillerechner v1.0"+Chr(10)+Chr(13)
        Text$+LSet("",17,Chr(175))+Chr(10)+Chr(13)
        Text$+"by"+Chr(10)+Chr(13)
        Text$+"Stefan Moebius"+Chr(10)+Chr(13)
        Text$+""+Chr(10)+Chr(13)
        
        Text$+"Haftungsausschluss:"+Chr(10)+Chr(13)
        Text$+"Die Benutzung dieser Software geschieht auf eigene Gefahr."+Chr(10)+Chr(13)      

        Text$+""+Chr(10)+Chr(13)
        
        Text$+"Kontakt:"+Chr(10)+Chr(13)
        Text$+"Email: MoebiusStefan@AOL.COM"+Chr(10)+Chr(13)
        
        MessageRequester("Info",Text$,#MB_ICONINFORMATION)
        
    EndSelect   
    
  EndIf    
  
Until Event=#PB_Event_CloseWindow

DestroyIcon_(Icon)
CloseFont(1)

End
; ExecutableFormat=
; Executable=C:\Dokumente und Einstellungen\Administrator\Eigene Dateien\beer.exe
; EOF