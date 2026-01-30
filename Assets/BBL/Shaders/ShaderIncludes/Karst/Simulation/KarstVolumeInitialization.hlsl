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
            material.waterAmount = 0;
            material.acidConcentration = 0;
            return material;
        }
    }
    
    KarstMaterial material;
    material.materialIndex = 0;
    material.density = 0;
    material.waterAmount = 0;
    material.acidConcentration = 0;
    return material;
}

float GetFractureDensity(uint3 id)
{
    float3 uvw = GetUvw(id);
    float2 uv = uvw.xz;
    float height = uvw.y;
    
    Fracture fracture = GetFractureNoise(uv);
    float baseHeight = _FloorAmount + _StoneAmount;
    float fractureHeight = baseHeight - fracture.height * _StoneAmount * 0.2;
    float voxelHeight = rcp(_SimulationDimensions.y);
    
    float fractureHeightMin = fractureHeight - voxelHeight * 1.5;
    float fractureHeightMax = fractureHeight + voxelHeight * 1.5;
    float minHeightMask = step(fractureHeightMin, height);
    float maxHeightMask = step(height, fractureHeightMax);
    float heightMask = minHeightMask * maxHeightMask;

    return 1 - (1 - fracture.density) * heightMask;
}

#endif
