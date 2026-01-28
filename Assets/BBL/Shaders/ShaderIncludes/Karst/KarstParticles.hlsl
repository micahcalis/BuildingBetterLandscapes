#ifndef KARST_PARTICLES_INCLUDED
#define KARST_PARTICLES_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Karst/Simulation/KarstCore.hlsl"

#define DENSITY_EPS 1e-4
#define NUM_MATS 3

struct KarstParticle
{
    float3 localPos;
    int materialIndex;
    float density;
};

float4x4 _ParticleToWorld;
StructuredBuffer<KarstParticle> _ParticleBuffer;
int _AppendMode;

float3 GetWorldSpacePosition(KarstParticle particle, float3 vertexPos)
{
    float3 positionOS = particle.localPos + vertexPos;
    return mul(_ParticleToWorld, float4(positionOS, 1)).xyz;
}

float3 GetLocalPosition(int3 id)
{
    float3 halfDim = _SimulationDimensions * 0.5;
    return (float3)id - halfDim;
}

bool AppendParticles()
{
    return _AppendMode == 0;
}

void TryAppendParticle(int3 id,
    Texture3D<float4> kartsVolume,
    AppendStructuredBuffer<KarstParticle> particleBuffer)
{
    float4 sample = kartsVolume[id];
    
    if (sample.g <= DENSITY_EPS)
        return;

    KarstParticle particle;
    particle.localPos = GetLocalPosition(id);
    particle.materialIndex = GetMaterialIndex(sample.r);
    particle.density = sample.g;
    particleBuffer.Append(particle);
}

void TryAppendHologram(int3 id,
    Texture3D<float4> kartsVolume,
    AppendStructuredBuffer<KarstParticle> particleBuffer)
{
    float4 sample = kartsVolume[id];

    if (sample.g > DENSITY_EPS)
        return;

    KarstParticle particle;
    particle.localPos = GetLocalPosition(id);
    particle.materialIndex = GetMaterialIndex(sample.r);
    particle.density = sample.g;
    particleBuffer.Append(particle);
}

#endif