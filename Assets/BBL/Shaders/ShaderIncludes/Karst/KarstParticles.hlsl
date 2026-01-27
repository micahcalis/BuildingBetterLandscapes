#ifndef KARST_PARTICLES_INCLUDED
#define KARST_PARTICLES_INCLUDED

#define ALPHA_EPS 1e-4

struct KarstParticle
{
    float3 localPos;
    float3 color;
    float opacity;
};

float4x4 _ParticleToWorld;
float3 _SimulationDimensions;
StructuredBuffer<KarstParticle> _ParticleBuffer;

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

void TryAppendParticle(int3 id,
    Texture3D<float4> kartsVolume,
    AppendStructuredBuffer<KarstParticle> particleBuffer)
{
    if (any(id >= (int3)_SimulationDimensions)) 
        return;
    
    float4 sample = kartsVolume[id];
    
    if (sample.a <= ALPHA_EPS)
        return;

    KarstParticle particle;
    particle.localPos = GetLocalPosition(id);
    particle.color = sample.rgb;
    particle.opacity = sample.a;
    particleBuffer.Append(particle);
}

#endif