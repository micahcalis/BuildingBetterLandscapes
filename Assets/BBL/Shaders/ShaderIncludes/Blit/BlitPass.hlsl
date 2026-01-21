#ifndef BLIT_PASS_INCLUDED
#define BLIT_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

static const float2 FULLSCREEN_VERTICES[4] = 
{ 
    float2(-1, -1), 
    float2(-1, 1), 
    float2(1, -1),
    float2(1, 1)
};

TEXTURE2D(_BlitSource);
SAMPLER(sampler_BlitSource);
float4 _BlitSource_ST;
float4 _BlitSource_TexelSize;

struct MeshDataBlit
{
    float4 positionOS  : POSITION;
    float2 uv          : TEXCOORD0;
};

struct VertDataBlit
{
    float4 positionCS  : SV_POSITION;
    float2 uv          : TEXCOORD0;
};

struct FragNormalOutput
{
    float4 normal : SV_Target;
    float depth : SV_Depth;
};

VertDataBlit VertBlit(MeshDataBlit input)
{
    VertDataBlit output = (VertDataBlit)0;
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.uv = TRANSFORM_TEX(input.uv, _BlitSource);
    return output;
}

VertDataBlit VertBlitQuad(MeshDataBlit input, uint vertexID : SV_VERTEXID)
{
    VertDataBlit output = (VertDataBlit)0;
    output.positionCS = float4(FULLSCREEN_VERTICES[vertexID], 0.0, 1.0);
    
    #if UNITY_UV_STARTS_AT_TOP
    if (_ProjectionParams.x < 0.0)
        output.positionCS.y = -output.positionCS.y;
    #endif
    
    output.uv = input.uv;

    return output;
}

#endif