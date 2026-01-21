#ifndef CRYSTAL_LANDSCAPE_INCLUDED
#define CRYSTAL_LANDSCAPE_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Blit/BlitPass.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/SphereTracing/SphereTracingFunctions.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/SphereTracing/SphereTracingParams.hlsl"

float4 CrystalFrag(VertDataBlit input) : SV_TARGET
{
    return float4(input.uv, 0, 1);
}

#endif