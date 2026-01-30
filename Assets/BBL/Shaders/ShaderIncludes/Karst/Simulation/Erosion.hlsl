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

float _ErosionRate;

float GetErosion(Flow inflow, ErosionWeights weights)
{
    float acidConcentration = ResolveAcidMass(inflow.waterFlow, inflow.acidMass);
    float mechanicalStress = inflow.waterFlow * weights.mechanical;
    float chemicalStress = (acidConcentration * weights.chemical) * inflow.waterFlow;
    float totalErosion = (mechanicalStress + chemicalStress) * _ErosionRate * _DeltaTime;
    return totalErosion;
}

// float GetSolutionalStope(Flow corrosionFlow, float totalAirVolume, ErosionWeights weights)
// {
//     float acidConcentration = ResolveAcidMass(corrosionFlow.waterFlow, corrosionFlow.acidMass);
//     float chemicalStress = (acidConcentration * weights.chemical) * corrosionFlow.waterFlow * CORROSION_FACTOR;
//     float tensionStress = totalAirVolume * weights.tension * TENSION_FACTOR;
//     float solutionalStope = (chemicalStress + tensionStress) * _ErosionRate * _DeltaTime * 10;
//     return solutionalStope;
// }

void ErodeMaterial(Flow inflow, inout KarstMaterial voxel)
{
    ErosionWeights weights = GetWeights(voxel.materialIndex);
    float erosion = GetErosion(inflow, weights);
    voxel.density -= erosion;
    voxel.density = max(voxel.density, 0.0f);
}

// // Helper to check horizontal structural integrity
// float GetStructuralSupport(RWTexture3D<float4> target, int3 id)
// {
//     float support = 0;
//     // Check 4 horizontal neighbors (North, South, East, West)
//     int3 offsets[4] = { int3(1,0,0), int3(-1,0,0), int3(0,0,1), int3(0,0,-1) };
//     
//     [unroll]
//     for(int k = 0; k < 4; k++)
//     {
//         KarstMaterial n = SampleVoxel(id + offsets[k], target);
//         // If neighbor is solid, it provides support (0.25 per neighbor)
//         if (!IsAir(n.density)) 
//             support += 0.25f;
//     }
//     return support; // 1.0 = Fully Supported (Flat Roof), 0.0 = Floating Tip
// }
//
// void SolutionalStoping(RWTexture3D<float4> erosionTarget, int3 id, inout KarstMaterial voxel)
// {
//     Flow corrosionFlow = (Flow)0;
//     float totalAirVolume = 0;
//
//     [unroll(STOPING_STEPS)]
//     for (int i = 1; i <= STOPING_STEPS; i++)
//     {
//         int3 coord = id + int3(0, -1, 0) * i; // Look Down
//
//         if (ThreadOutOfBounds(coord)) break;
//         
//         KarstMaterial currentVoxel = SampleVoxel(coord, erosionTarget);
//
//         // If we hit a floor, the tension ends.
//         if (!IsAir(currentVoxel.density)) break;
//         
//         // FIX 1: Distance Falloff (Inverse Square or Linear Decay)
//         // Voids further away exert less tension.
//         float decay = 1.0f / (float)i; 
//         
//         corrosionFlow = AddFlows(corrosionFlow, CreateFlow(currentVoxel.waterAmount, currentVoxel.acidConcentration));
//         
//         // Accumulate void, but weighted by distance
//         totalAirVolume += (1.0f - currentVoxel.density) * decay;
//     }
//
//     ErosionWeights weights = GetWeights(voxel.materialIndex);
//     
//     // FIX 2: Structural Support Check
//     // If the voxel is well-supported by neighbors, reduce tension drastically.
//     float support = GetStructuralSupport(erosionTarget, id);
//     float structuralFactor = 1.0f - (support * 0.8f); // Even fully supported allows 20% erosion (slow drip)
//
//     // Recalculate Stress with the new factors
//     float acidConcentration = ResolveAcidMass(corrosionFlow.waterFlow, corrosionFlow.acidMass);
//     
//     // Note: We multiply chemical stress by decay too (water far below steams less)
//     float chemicalStress = (acidConcentration * weights.chemical) * corrosionFlow.waterFlow * CORROSION_FACTOR;
//     
//     // Tension is now dampened by structural support
//     float tensionStress = totalAirVolume * weights.tension * TENSION_FACTOR * structuralFactor;
//     
//     float solutionalStope = (chemicalStress + tensionStress) * _ErosionRate * _DeltaTime;
//     
//     voxel.density -= solutionalStope;
//     
//     // Safety clamp so we don't vanish instantly
//     voxel.density = max(voxel.density, 0.0f);
// }
#endif