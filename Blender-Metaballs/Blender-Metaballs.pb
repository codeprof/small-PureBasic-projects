

Procedure OutputLine(line.s)
  Debug line.s
EndProcedure


Procedure MetaBlend_Init()
  OutputLine("import bpy")
  OutputLine("metaball = bpy.data.metaballs.new('test')")
  OutputLine("obj = bpy.data.objects.new('test', metaball)")
  OutputLine("bpy.context.scene.objects.link(obj)")
  OutputLine("metaball.resolution = 0.2")
  OutputLine("metaball.render_resolution = 0.02")
EndProcedure

Procedure MetaBlend_AddBall(x.f,y.f,z.f,sz.f,tube,neg)
  OutputLine("el= metaball.elements.new()")
  OutputLine("el.co = ("+StrF(x,3)+","+StrF(y,3)+","+StrF(z,3)+")")
  ;  OutputLine("el.dims = ("+StrF(x,3)+","+StrF(y,3)+","+StrF(z,3)+")")
  OutputLine("el.radius = " +StrF(sz,3))
  OutputLine("el.stiffness = 10.0")  
  If tube
    OutputLine("el.type= 'CAPSULE'")   
  EndIf
  If neg
    OutputLine("el.use_negative= True")       
  EndIf
EndProcedure


Procedure MetaBlend_AddBall2(x.f,y.f,z.f,sz.f,rnd.f)
  z = Random(5)+1
  For i = 0 To z
    dx.f = Random(1000)/1000.0 * rnd - Random(1000)/1000.0 * rnd 
    dy.f = Random(1000)/1000.0 * rnd - Random(1000)/1000.0 * rnd 
    dz.f = Random(1000)/1000.0 * rnd - Random(1000)/1000.0 * rnd 
    dsz.f  = Random(1000)/1000.0 * rnd - Random(1000)/1000.0 * rnd 
    
    OutputLine("el= metaball.elements.new()")
    OutputLine("el.co = ("+StrF(x+dx,3)+","+StrF(y+dy,3)+","+StrF(z+dz,3)+")")
    OutputLine("el.radius = " +StrF(sz+dsz,3))
  Next
EndProcedure


Procedure MetaBlend_Line(sx.f,sy.f,sz.f,ex.f,ey.f,ez.f,size.f,stepsize.f,rnd.f)
  
  dx.f = ex - sx
  dy.f = ey - sy
  dz.f = ez - sz
  dist.f = Sqr(dx*dx + dy*dy +dz*dz)
  
  pos.f = 0
  Repeat
    rel.f = pos / dist
    px.f = sx + dx * rel
    py.f = sy + dy * rel    
    pz.f = sz + dz * rel
    px.f = px + Random(1000)/1000.0 * rnd - Random(1000)/1000.0 * rnd 
    py.f = py + Random(1000)/1000.0 * rnd - Random(1000)/1000.0 * rnd 
    pz.f = pz + Random(1000)/1000.0 * rnd - Random(1000)/1000.0 * rnd     
    sizetmp.f = size+ Random(1000)/1000.0 * rnd
    ;MetaBlend_AddBall(px,py,pz,sizetmp.f)
    pos + stepsize
  Until pos > dist
EndProcedure  


  
MetaBlend_Init()
;MetaBlend_Line(0,0,0,5,5,5,0.25, 0.25,0.1)

;MetaBlend_Line(0,0,0,0,5,5,0.25, 0.25,0.1)
;MetaBlend_Line(0,0,0,5,0,5,0.25, 0.25,0.1)
;MetaBlend_Line(0,0,0,5,5,0,0.25, 0.25,0.1)

MetaBlend_AddBall(0,0,0,5,#False, #False)

For z =0 To 80
  p.f = Random(10000)/100.0
  p2.f = Random(10000)/100.0
  xf.f = Sin(p) *Cos(p2)* 5
  yf.f =Sin(p) *Sin(p2) * 5
  zf.f = -Cos(p) * 5
MetaBlend_AddBall(xf,yf,zf,Random(1000)/1000.0*2.5+0.2,#False,#True)
Next
;For t=0 To 40
;MetaBlend_AddBall(Random(10000)/1000.0,Random(10000)/1000.0,Random(10000)/1000.0,1)
;Next

; MetaBlend_AddBall(0,0,0,1)
; MetaBlend_AddBall(5,5,5,1)
; MetaBlend_AddBall(0,5,5,1)
; MetaBlend_AddBall(5,0,5,1)
; MetaBlend_AddBall(5,5,0,1)
