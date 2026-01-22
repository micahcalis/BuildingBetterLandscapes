#ifndef SPHERE_TRACING_PARAMS_INCLUDED
#define SPHERE_TRACING_PARAMS_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/SphereTracing/SphereTracingFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

int _RayMaxSteps;
float _RayMaxDistance;

Ray GetRay(float3 positionWS)
{
    Ray ray;
    ray.origin = positionWS;
    ray.direction = normalize(positionWS - GetCameraPositionWS());
    return ray;
}

SphereTraceInput GetSphereTracingInput(float3 positionWS)
{
    SphereTraceInput input;
    input.ray = GetRay(positionWS);
    input.maxSteps = _RayMaxSteps;
    input.maxDistance = _RayMaxDistance;
    return input;
}

#endif