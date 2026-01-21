#ifndef SPHERE_TRACING_FUNCTIONS_INCLUDED
#define SPHERE_TRACING_FUNCTIONS_INCLUDED

#define DIST_EPS 1e-6

struct Ray
{
    float3 origin;
    float3 direction;
};

struct SphereTraceInput
{
    Ray ray;
    int maxSteps;
    float maxDistance;
};

struct SphereTraceOutput
{
    float3 positionWS;
    float3 normalWS;
    float totalDist;
    int iterations;
    bool hit;
};

float PlaneSDF(float3 positionWS, float3 planeNormal, float offset)
{
    return dot(positionWS, planeNormal) + offset;
}

#endif