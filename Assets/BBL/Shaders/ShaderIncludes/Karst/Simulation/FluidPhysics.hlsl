#ifndef FLUID_PHYSICS_INCLUDED
#define FLUID_PHYSICS_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Karst/Simulation/Flux.hlsl"

struct PressurePair
{
    float waterAmount;
    float height;
};

#define INJECT_WALL_THICKNESS 2
#define INJECT_WALL_AMOUNT 1.0f
#define EJECT_WALL_THICKNESS 2
#define EJECT_WALL_AMOUNT 0.0f
#define F_GRAVITY 9.81f

float _WaterInjectRate;
float _WaterPermThreshold;

bool IsOnStoneLayer(float height, float floorAmount, float stoneAmount)
{
    return height >= floorAmount && height <= stoneAmount;
}

bool IsPermeable(float density)
{
    return density <= _WaterPermThreshold;
}

bool CanInjectWater(KarstMaterial voxel)
{
    if (voxel.materialIndex != STONE && !IsAir(voxel.density))
        return false;

    return IsPermeable(voxel.density);
}

bool IsInjectWall(int axisCoord)
{
    return axisCoord < INJECT_WALL_THICKNESS;
}

bool IsEjectWall(int axisCoord, int axisLength)
{
    return axisCoord >= axisLength - EJECT_WALL_THICKNESS;
}

void InjectWater(RWTexture3D<float4> injectTarget, KarstMaterial voxel, uint3 id, float deltaTime)
{
    voxel.waterAmount += _WaterInjectRate * deltaTime;
    voxel.waterAmount = min(voxel.waterAmount, 1);

    if (IsInjectWall(id.x))
        voxel.waterAmount = INJECT_WALL_AMOUNT;
    else if (IsEjectWall(id.x, _SimulationDimensions.x))
        voxel.waterAmount = EJECT_WALL_AMOUNT;
    
    injectTarget[id] = ResolveMaterial(voxel);
}

bool HasWater(KarstMaterial voxel)
{
    return voxel.waterAmount > 1e-2;
}

PressurePair GetPressurePair(RWTexture3D<float4> fluxSource, uint3 id)
{
    PressurePair pair;
    
    if (any(id < 0) || any(id >= _SimulationDimensions))
    {
        pair.waterAmount = 0;
        pair.height = id.y; 
        return pair;
    }
    
    pair.waterAmount = fluxSource[id].b;
    pair.height = id.y;
    return pair;
}

float CalculatePressureDelta(PressurePair pairA, PressurePair pairB)
{
    return (pairA.waterAmount + pairA.height) - (pairB.waterAmount + pairB.height);
}

float GetFluxAcceleration(PressurePair pairA, PressurePair pairB, float deltaTime)
{
    float pressure = CalculatePressureDelta(pairA, pairB);
    return pressure * deltaTime * F_GRAVITY;
}

void ApplyDirectionalFlux(int index, float fluxAccel, inout Flux flux)
{
    float oldFlux = GetFluxValByIndex(index, flux);
    float newFlux = oldFlux + fluxAccel;
    newFlux *= FLUX_DAMPING;
    newFlux = max(newFlux, 0);
    SetFluxValByIndex(index, newFlux, flux);
}

void NormalizeFlux(float maxWater, inout Flux flux)
{
    float fluxSum = SumFlux(flux);
    float normVal = fluxSum < maxWater ? 1 :
        maxWater / max(fluxSum, 1e-4);

    ScaleFlux(normVal, flux);
}

void UpdateFlux(RWTexture3D<float4> fluxSource, int3 id, float deltaTime)
{
    PressurePair pairA = GetPressurePair(fluxSource, id);
    Flux flux = GetFlux(id, _SimulationDimensions);

    [unroll(F_DIR_COUNT)]
    for (int i = 0; i < F_DIR_COUNT; i++)
    {
        int3 coord = id + FLUX_DIRS[i];
        PressurePair pairB = GetPressurePair(fluxSource, coord);
        float fluxAccel = GetFluxAcceleration(pairA, pairB, deltaTime);
        ApplyDirectionalFlux(i, fluxAccel, flux);
    }

    NormalizeFlux(pairA.waterAmount, flux);
    SetFlux(flux, id, _SimulationDimensions);
}

float GetTotalOutflow(int3 id)
{
    Flux outflowFlux = GetFlux(id, _SimulationDimensions);
    return SumFlux(outflowFlux);
}

float GetTotalInflow(int3 id)
{
    Flux inflowFlux = (Flux)0;
    
    [unroll(F_DIR_COUNT)]
    for (int i = 0; i < F_DIR_COUNT; i++)
    {
        int3 coord = id + FLUX_DIRS[i];
        if (ThreadOutOfBounds(coord))
            continue;

        Flux flux = GetFlux(coord, _SimulationDimensions);
        float inflow = GetFluxValByIndex(GetOppositeIndex(i), flux);
        SetFluxValByIndex(i, inflow, inflowFlux);
    }

    return SumFlux(inflowFlux);
}

#endif
