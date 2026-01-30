#ifndef FLUID_PHYSICS_INCLUDED
#define FLUID_PHYSICS_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Karst/Simulation/Flux.hlsl"
#include "Assets/BBL/Shaders/ShaderIncludes/Karst/Simulation/Flow.hlsl"

struct PressurePair
{
    float waterAmount;
    float height;
};

#define INJECT_WALL_THICKNESS 4
#define INJECT_WALL_AMOUNT 0.0f
#define EJECT_WALL_THICKNESS 0
#define EJECT_WALL_AMOUNT 0.0f
#define PERM_THRESH 0.8f
#define F_GRAVITY 2.0f
#define MAX_FLUX_ACCEL 5.0f
#define HEIGHT_SCALAR 0.1f
#define RAIN_ACID 1.0f
#define KARST_ACID 0.1f
#define FLUX_DAMPING 0.8f

float _WaterInjectRate;

bool IsOnStoneLayer(float height, float floorAmount, float stoneAmount)
{
    return height >= floorAmount && height <= stoneAmount;
}

bool IsPermeable(float density)
{
    return density <= PERM_THRESH;
}

bool CanInjectWater(KarstMaterial voxel, RWTexture3D<float4> injectTarget, int3 id)
{
    if (!IsPermeable(voxel.density))
        return false;
    
    KarstMaterial voxelAbove = SampleVoxel(id + int3(0, 1, 0), injectTarget);
    return !IsPermeable(voxelAbove.density);
}

bool IsInjectWall(int axisCoord)
{
    return axisCoord < INJECT_WALL_THICKNESS;
}

bool IsEjectWall(int axisCoord, int axisLength)
{
    return axisCoord >= axisLength - EJECT_WALL_THICKNESS;
}

float GetHeightGradient(float height)
{
    return smoothstep(_FloorAmount, _StoneAmount, height);
}

float GetInjectMultiplier(int3 id)
{
    float3 uvw = GetUvw(id);
    float2 uv = uvw.xz;
    float height = uvw.y;
    
    float noise = GetWaterColumnNoise(uv);
    float gradient = GetHeightGradient(height);
    return noise * gradient;
}

void InjectWater(RWTexture3D<float4> injectTarget, KarstMaterial voxel, uint3 id, float deltaTime)
{
    float multiplier = GetInjectMultiplier(id);
    float inject = _WaterInjectRate * deltaTime * multiplier;
    Flow injectFlow = CreateFlow(inject, RAIN_ACID * multiplier);
    Flow baseFlow = GetBaseFlow(voxel);
    Flow netFlow = AddFlows(injectFlow, baseFlow);
    voxel.waterAmount = min(netFlow.waterFlow, 1.0f);
    voxel.acidConcentration = ResolveAcidMass(netFlow.waterFlow, netFlow.acidMass);
    
    injectTarget[id] = ResolveMaterial(voxel);
}

bool HasWater(KarstMaterial voxel)
{
    return voxel.waterAmount > 1e-2;
}

PressurePair GetPressurePair(RWTexture3D<float4> fluxSource, int3 id)
{
    PressurePair pair;
    
    if (any(id < 0) || any(id >= _SimulationDimensions))
    {
        pair.waterAmount = 0;
        pair.height = id.y * HEIGHT_SCALAR; 
        return pair;
    }
    
    pair.waterAmount = fluxSource[id].b;
    pair.height = id.y * HEIGHT_SCALAR;
    return pair;
}

float CalculatePressureDelta(PressurePair pairA, PressurePair pairB)
{
    return (pairA.waterAmount + pairA.height) - (pairB.waterAmount + pairB.height);
}

float GetFluxAcceleration(PressurePair pairA, PressurePair pairB, float deltaTime)
{
    float pressure = CalculatePressureDelta(pairA, pairB);
    float acceleration = pressure * deltaTime * F_GRAVITY;
    return clamp(acceleration, -MAX_FLUX_ACCEL, MAX_FLUX_ACCEL);
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

        if (coord.x < 0)
        {
            SetFluxValByIndex(i, 0, flux); 
            continue; 
        }
        
        PressurePair pairB = GetPressurePair(fluxSource, coord);
        float fluxAccel = GetFluxAcceleration(pairA, pairB, deltaTime);
        ApplyDirectionalFlux(i, fluxAccel, flux);
    }

    NormalizeFlux(pairA.waterAmount, flux);
    SetFlux(flux, id, _SimulationDimensions);
}

Flow GetTotalOutflow(int3 id, float currentAcidConcentration, RWTexture3D<float4> fluxSource)
{
    Flux outflowFlux = GetFlux(id, _SimulationDimensions);
    float totalWaterOut = 0;

    [unroll(F_DIR_COUNT)]
    for (int i = 0; i < F_DIR_COUNT; i++)
    {
        float dirFlux = GetFluxValByIndex(i, outflowFlux);

        if (dirFlux <= 0.00001f)
            continue; 

        int3 coord = id + FLUX_DIRS[i];

        if (ThreadOutOfBounds(coord))
            continue; 

        KarstMaterial neighbor = SampleVoxel(coord, fluxSource);
        if (IsPermeable(neighbor.density)) 
        {
            totalWaterOut += dirFlux;
        }
    }

    Flow result;
    result.waterFlow = totalWaterOut;
    result.acidMass = totalWaterOut * currentAcidConcentration; 
    
    return result;
}

Flow GetTotalInflow(RWTexture3D<float4> fluxSource, int3 id)
{
    Flow totalInflow;
    totalInflow.waterFlow = 0;
    totalInflow.acidMass = 0;
    
    [unroll(F_DIR_COUNT)]
    for (int i = 0; i < F_DIR_COUNT; i++)
    {
        int3 coord = id + FLUX_DIRS[i];
        if (ThreadOutOfBounds(coord))
            continue;
        
        KarstMaterial neighbor = SampleVoxel(coord, fluxSource);
        if (!IsPermeable(neighbor.density))
            continue;
        
        Flux flux = GetFlux(coord, _SimulationDimensions);
        float inflow = GetFluxValByIndex(GetOppositeIndex(i), flux);

        Flow neighborFlow;
        neighborFlow.waterFlow = inflow;
        neighborFlow.acidMass = inflow * neighbor.acidConcentration;
        
        totalInflow = AddFlows(totalInflow, neighborFlow);
    }

    return totalInflow;
}

#endif
