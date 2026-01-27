#ifndef KARST_PARTICLES_PASS_INCLUDED
#define KARST_PARTICLES_PASS_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Karst/KarstParticles.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

struct ParticleMeshData
{
    float4 positionOS : POSITION;
};

struct ParticleVertData
{
    float4 positionCS : SV_POSITION;
    int instanceId    : TEXCOORD0;
};

ParticleVertData KarstParticleVert(ParticleMeshData input, uint instanceId : SV_InstanceID)
{
    ParticleVertData output;
    KarstParticle particle = _ParticleBuffer[instanceId];
    float3 positionWS = GetWorldSpacePosition(particle, input.positionOS);
    output.positionCS = TransformWorldToHClip(positionWS);
    output.instanceId = instanceId;
    return output;
}

float4 KarstParticleFrag(ParticleVertData input) : SV_TARGET
{
    KarstParticle particle = _ParticleBuffer[input.instanceId];
    return float4(particle.color, 1);
}

#endif
