#ifndef CRYSTAL_INPUT_INCLUDED
#define CRYSTAL_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_TerrainHeightMap);
SAMPLER(sampler_TerrainHeightMap);
float3 _TerrainPos;
float3 _TerrainSize;
float _CellDensity;
float _AngleOffset;
float _NoiseIntensity;
float4 _BaseColor;
float4 _ShadowColor;
float4 _SkyColor;
float4 _HorizonColor;
float _SkyGradExp;
float _ShadowIntensity;
float _SpecularExp;
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
float _TriBlend;
float4 _BaseMap_ST;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
float _NormalStrength;
float _AmbientOccExp;
float _AmbientOccContrast;
float _SpecularIntensity;
float _FresnelExp;
float _FresnelIntensity;

#endif