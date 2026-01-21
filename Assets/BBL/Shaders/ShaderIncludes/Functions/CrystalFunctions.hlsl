#ifndef CRYSTAL_FUNCTIONS_INCLUDED
#define CRYSTAL_FUNCTIONS_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/SphereTracing/SphereTracingFunctions.hlsl" 

float GetCrystalDist(float3 positionWS)
{
    return length(positionWS) - 2;
}

float3 GetNormal(float3 positionWS)
{
    float eps = 0.001;
    float dx = GetCrystalDist(positionWS + float3(eps, 0, 0)) - 
    GetCrystalDist(positionWS - float3(eps, 0, 0));
    
    float dy = GetCrystalDist(positionWS + float3(0, eps, 0)) - 
    GetCrystalDist(positionWS - float3(0, eps, 0));
    
    float dz = GetCrystalDist(positionWS + float3(0, 0, eps)) - 
    GetCrystalDist(positionWS - float3(0, 0, eps));
    
    return normalize(float3(dx, dy, dz));
}

SphereTraceOutput CrystalTrace(SphereTraceInput input)
{
    SphereTraceOutput output;
    output.positionWS = input.ray.origin;
    output.normalWS = (float3)0;
    output.totalDist = 0;
    output.hit = false;

    [loop]
    for (output.iterations = 0; output.iterations < input.maxSteps; output.iterations++)
    {
        float distance = GetCrystalDist(output.positionWS);

        if (distance < DIST_EPS)
        {
            output.hit = true;
            output.normalWS = GetNormal(output.positionWS);
            return output;
        }

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