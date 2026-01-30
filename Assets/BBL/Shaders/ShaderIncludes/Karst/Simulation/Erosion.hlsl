#ifndef EROSION_INCLUDED
#define EROSION_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Karst/Simulation/Flow.hlsl"

struct ErosionWeights
{
    float chemical;
    float mechanical;
};

ErosionWeights CreateErosionWeights(float chemical, float mechanical)
{
    ErosionWeights weights;
    weights.chemical = chemical;
    weights.mechanical = mechanical;
    return weights;
}

#define STONE_WEIGHTS CreateErosionWeights(1.5, 0.05)
#define FLOOR_WEIGHTS CreateErosionWeights(0.01, 0.01)
#define CLAY_WEIGHTS  CreateErosionWeights(0.0, 1.0)
#define SAND_WEIGHTS  CreateErosionWeights(0.0, 2.5)

ErosionWeights GetWeights(int materialIndex)
{
    if (materialIndex == STONE)
        return STONE_WEIGHTS;
    else if (materialIndex == FLOOR)
        return FLOOR_WEIGHTS;
    else if (materialIndex == CLAY)
        return CLAY_WEIGHTS;
    else if (materialIndex == SAND)
        return SAND_WEIGHTS;
    return (ErosionWeights)0;
}

#define STOPING_STEPS 10
#define CORROSION_FACTOR 1
#define TENSION_FACTOR 0.2
#define CONSUME_FACTOR 0.9f

float _ErosionRate;

float GetErosion(Flow inflow, ErosionWeights weights)
{
    float acidConcentration = ResolveAcidMass(inflow.waterFlow, inflow.acidMass);
    float mechanicalStress = inflow.waterFlow * weights.mechanical;
    float chemicalStress = (acidConcentration * weights.chemical) * inflow.waterFlow;
    float totalErosion = (mechanicalStress + chemicalStress) * _ErosionRate * _DeltaTime;
    return totalErosion;
}

void ConsumeAcid(float erosion, inout KarstMaterial voxel)
{
    if (voxel.materialIndex == STONE && voxel.waterAmount > 0.0001f)
    {
        float acidConsumed = erosion * CONSUME_FACTOR;
        float currentAcidMass = voxel.waterAmount * voxel.acidConcentration;
        float newAcidMass = max(currentAcidMass - acidConsumed, 0.0f);
        voxel.acidConcentration = newAcidMass / voxel.waterAmount;
    }
}

void ErodeMaterial(Flow inflow, inout KarstMaterial voxel)
{
    ErosionWeights weights = GetWeights(voxel.materialIndex);
    float erosion = GetErosion(inflow, weights);
    voxel.density -= erosion;
    voxel.density = max(voxel.density, 0.0f);
    ConsumeAcid(erosion, voxel);
}

#endif