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

float BoxSDF(float3 positionWS, float3 scale)
{
    float3 q = abs(positionWS) - scale;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

#endif