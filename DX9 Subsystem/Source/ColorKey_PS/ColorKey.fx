// ColorKeying Pixelshader (c) 2006 Stefan Moebius

string XFile = "test.x";
int    BCLR = 0xffffffff;

texture Tex0 < string name = "test.bmp"; >;

float4 Trans: Trans;

sampler Sampler = sampler_state
{
    Texture   = (Tex0);
    MipFilter = POINT;
    MinFilter = POINT;
    MagFilter = POINT;
};

float4 PS(
    float4 Diff : COLOR0,
    float4 Spec : COLOR1,
    float2 Tex  : TEXCOORD0) : COLOR
{
float4 OutColor;
  
OutColor=tex2D(Sampler,Tex);
if (all(abs(OutColor.rgb-Trans.rgb)<0.004)){ 
discard;
}
return OutColor*Diff;
}


technique ColorKey
{
    pass P0
    {
        PixelShader  = compile ps_1_4 PS();
    }  
}

