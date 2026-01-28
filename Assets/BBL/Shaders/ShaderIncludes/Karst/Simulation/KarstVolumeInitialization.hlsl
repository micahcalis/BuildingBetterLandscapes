#ifndef KARST_VOLUME_INITIALIZATION_INCLUDED
#define KARST_VOLUME_INITIALIZATION_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Karst/Simulation/KarstNoise.hlsl"

float _FloorAmount;
float _StoneAmount;
float _ClayAmount;
float _SandAmount;

float GetLayerAmount(int materialIndex)
{
    switch (materialIndex)
    {
        case FLOOR:
            return _FloorAmount;
        case STONE:
            return _StoneAmount;
        case CLAY:
            return _ClayAmount;
        case SAND:
            return _SandAmount;
        default:
            return 0;
    }
}

KarstMaterial GetMaterial(int3 id)
{
    float3 uvw = GetUvw(id);
    float2 uv = uvw.xz;
    float height = uvw.y;
    float heightSum = 0;

    [unroll(NUM_MATS)]
    for (int i = 0; i < NUM_MATS; i++)
    {
        float noise = GetLayerNoise(uv, i);
        float layerVal = GetLayerAmount(i);
        heightSum += noise + layerVal;
        
        if (height <= heightSum)
        {
            KarstMaterial material;
            material.materialIndex = i;
            material.density = 1;
            return material;
        }
    }
    
    KarstMaterial material;
    material.materialIndex = 0;
    material.density = 0;
    return material;
}

#endif
