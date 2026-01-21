#ifndef CRYSTAL_LANDSCAPE_INCLUDED
#define CRYSTAL_LANDSCAPE_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Blit/BlitPass.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/SphereTracing/SphereTracingFunctions.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/SphereTracing/SphereTracingParams.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/Functions/CrystalFunctions.hlsl"

float4 CrystalFrag(VertDataBlit input) : SV_TARGET
{
    float3 positionWS = ComputeWorldSpacePosition(input.uv, 0.1, UNITY_MATRIX_I_VP);
    SphereTraceInput sphereTraceInput = GetSphereTracingInput(positionWS);
    SphereTraceOutput output = CrystalTrace(sphereTraceInput);
    
    return float4(output.normalWS, 1);
}

#endif