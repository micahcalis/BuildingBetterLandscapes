#ifndef CRYSTAL_LANDSCAPE_INCLUDED
#define CRYSTAL_LANDSCAPE_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Blit/BlitPass.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/SphereTracing/SphereTracingFunctions.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/SphereTracing/SphereTracingParams.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/Functions/CrystalFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/Functions/CrystalLit.hlsl"

CrystalInput SetCrystalInput()
{
    CrystalInput crystalInput;
    crystalInput.terrainCorner = _TerrainPos;
    crystalInput.terrainSize = _TerrainSize.xz;
    crystalInput.terrainHeightScale = _TerrainSize.y * 2;
    crystalInput.terrainHeightMap = _TerrainHeightMap;
    crystalInput.terrainSampler = sampler_TerrainHeightMap;
    crystalInput.cellDensity = _CellDensity;
    crystalInput.angleOffset = _AngleOffset;
    crystalInput.noiseIntensity = _NoiseIntensity;
    return crystalInput;
}

float4 CrystalFrag(VertDataBlit input) : SV_TARGET
{
    float3 positionWS = ComputeWorldSpacePosition(input.uv, 10, UNITY_MATRIX_I_VP);
    SphereTraceInput sphereTraceInput = GetSphereTracingInput(positionWS);
    CrystalInput crystalInput = SetCrystalInput();
    SphereTraceOutput output = CrystalTrace(sphereTraceInput, crystalInput);

    float3 diffuse = GetTriplanar(_BaseMap,
        sampler_BaseMap,
        _TriBlend,
        output.positionWS,
        output.normalWS,
        _BaseMap_ST.x) * _BaseColor;

    float3 normalTangent = GetTriplanarNormal(_NormalMap,
        sampler_NormalMap,
        output.positionWS,
        output.normalWS,
        _BaseMap_ST,
        _TriBlend,
        _NormalStrength);

    CrystalLitInput crystalLit = SetCrystalLitInput(output.positionWS,
        normalTangent,
        sphereTraceInput.ray.direction,
        diffuse,
        _ShadowColor,
        _ShadowIntensity,
        _SkyColor,
        _SpecularExp,
        _SpecularIntensity,
        _FresnelExp,
        _FresnelIntensity);

    float ao = GetAmbientOcclusion(output.iterations,
        sphereTraceInput.maxSteps,
        _AmbientOccExp,
        _AmbientOccContrast);
    crystalLit.light.shadowAttenuation = ao;
    
    float3 litColor = CrystalLit(crystalLit);
    float3 skyColor = GetSkyColor(sphereTraceInput.ray.direction, _SkyColor, _HorizonColor, _SkyGradExp);
    float3 blendCol = output.hit ? litColor : skyColor;

    // /return saturate(dot(normalTangent, GetMainLight().direction));
    return float4(blendCol, 1);
}

#endif