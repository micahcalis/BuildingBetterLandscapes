#ifndef KARST_PARTICLES_PASS_INCLUDED
#define KARST_PARTICLES_PASS_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Karst/KarstParticles.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct ParticleMeshData
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
};

struct ParticleVertData
{
    float4 positionCS : SV_POSITION;
    int instanceId    : TEXCOORD0;
    float3 normalWS   : TEXCOORD1;
};

ParticleVertData KarstParticleVert(ParticleMeshData input, uint instanceId : SV_InstanceID)
{
    ParticleVertData output;
    KarstParticle particle = _ParticleBuffer[instanceId];
    float3 positionWS = GetWorldSpacePosition(particle, input.positionOS);
    output.positionCS = TransformWorldToHClip(positionWS);
    output.instanceId = instanceId;
    output.normalWS = input.normalOS;
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
    float NdotL = dot(_MainLightPosition, input.normalWS) * 0.5 + 0.5;
    return float4(color * NdotL, 1);
}

float4 KarstHologramFrag(ParticleVertData input) : SV_TARGET
{
    return _EmptyColor;
}

#endif
