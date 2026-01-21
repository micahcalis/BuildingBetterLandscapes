#ifndef CRYSTAL_FUNCTIONS_INCLUDED
#define CRYSTAL_FUNCTIONS_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/SphereTracing/SphereTracingFunctions.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/Functions/VoronoiFunctions.hlsl"

#define UP float3(0, 1, 0)

struct CrystalInput
{
    float3 terrainCorner;
    float2 terrainSize;
    float terrainHeightScale;
    Texture2D terrainHeightMap;
    SamplerState terrainSampler;
    float cellDensity;
    float angleOffset;
    float noiseIntensity;
};

float2 GetTerrainUV(float3 positionWS, float3 cornerPos, float2 size)
{
    float2 localPos = positionWS.xz - cornerPos.xz;
    return localPos / size;
}

float GetTerrainSample(CrystalInput crystalInput, float2 uv)
{
    float raw = SAMPLE_TEXTURE2D_LOD(crystalInput.terrainHeightMap,
        crystalInput.terrainSampler, uv, 0).r;
    return raw * crystalInput.terrainHeightScale;
}

float GetVoronoiDist(float2 uv, float cellDensity, float angleOffset, float noiseIntensity)
{
    Voronoi voronoi = Voronoi2D(uv, angleOffset, cellDensity);
    return voronoi.id * noiseIntensity;
}

float GetCrystalDist(CrystalInput crystalInput, float3 positionWS)
{
    float2 terrainUv = GetTerrainUV(positionWS, crystalInput.terrainCorner, crystalInput.terrainSize);
    
    if(terrainUv.x < 0 || terrainUv.x > 1 || terrainUv.y < 0 || terrainUv.y > 1) 
        return 10.0;

    float heightSample = GetTerrainSample(crystalInput, terrainUv);
    float noiseOffset = GetVoronoiDist(terrainUv, crystalInput.cellDensity, crystalInput.angleOffset, crystalInput.noiseIntensity);
    float verticalDist = positionWS.y - (heightSample - 5.0 + noiseOffset); 
    return verticalDist * 0.5; 
}

float3 GetNormal(CrystalInput crystalInput, float3 positionWS, float totalDist)
{
    float eps = 0.01 + totalDist * 0.01;
    float dx = GetCrystalDist(crystalInput, positionWS + float3(eps, 0, 0)) - 
    GetCrystalDist(crystalInput, positionWS - float3(eps, 0, 0));
    
    float dy = GetCrystalDist(crystalInput, positionWS + float3(0, eps, 0)) - 
    GetCrystalDist(crystalInput, positionWS - float3(0, eps, 0));
    
    float dz = GetCrystalDist(crystalInput, positionWS + float3(0, 0, eps)) - 
    GetCrystalDist(crystalInput, positionWS - float3(0, 0, eps));
    
    float3 n = normalize(float3(dx, dy, dz));
    
    return n;
}


float GetRefinedIntersection(SphereTraceInput input, CrystalInput crystalInput, float totalDist, float lastStepSize)
{
    float t_min = totalDist - lastStepSize;
    float t_max = totalDist;

    [unroll]
    for(int i = 0; i < 5; i++)
    {
        float t_mid = (t_min + t_max) * 0.5;
        float3 p_mid = input.ray.origin + input.ray.direction * t_mid;
        
        float h_mid = GetCrystalDist(crystalInput, p_mid);

        if (h_mid > 0.0)
            t_min = t_mid;
        else
            t_max = t_mid;
    }
    
    return t_max;
}

SphereTraceOutput CrystalTrace(SphereTraceInput input, CrystalInput crystalInput)
{
    SphereTraceOutput output;
    output.positionWS = input.ray.origin;
    output.normalWS = (float3)0;
    output.totalDist = 0;
    output.hit = false;
    float lastStepSize = 0;
    float pixelConeSize = 0.006;

    [loop]
    for (output.iterations = 0; output.iterations < input.maxSteps; output.iterations++)
    {
        float distance = GetCrystalDist(crystalInput, output.positionWS);
        float currentEps = max(DIST_EPS, output.totalDist * pixelConeSize);

        if (distance < currentEps)
        {
            output.hit = true;
            output.totalDist = GetRefinedIntersection(input, crystalInput, output.totalDist, lastStepSize);
            output.positionWS = input.ray.origin + input.ray.direction * output.totalDist;
            output.normalWS = GetNormal(crystalInput, output.positionWS, output.totalDist);
            return output;
        }

        lastStepSize = distance;
        output.totalDist += distance;
        output.positionWS = input.ray.origin + input.ray.direction * output.totalDist;

        if (output.totalDist > input.maxDistance)
        {
            output.hit = false;
            return output;
        }
    }

    return output;
}

#endif