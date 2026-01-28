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

float3 GetMaterialColor(int materialIndex)
{
    switch (materialIndex)
    {
        case FLOOR:
            return _FloorColor;
        case STONE:
            return _StoneColor;
        case CLAY:
            return _ClayColor;
        case SAND:
            return _SandColor;
        default:
            return 0;
    }
}

float4 KarstParticleFrag(ParticleVertData input) : SV_TARGET
{
    KarstParticle particle = _ParticleBuffer[input.instanceId];
    float3 color = GetMaterialColor(particle.materialIndex);
    return float4(color, 1);
}

#endif
