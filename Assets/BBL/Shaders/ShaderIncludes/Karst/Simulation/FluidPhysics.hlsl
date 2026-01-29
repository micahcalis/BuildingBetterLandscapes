#ifndef FLUID_PHYSICS_INCLUDED
#define FLUID_PHYSICS_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Karst/Simulation/Flux.hlsl"

#define INJECT_WALL_THICKNESS 2
#define INJECT_WALL_AMOUNT 1.0f
#define EJECT_WALL_THICKNESS 2
#define EJECT_WALL_AMOUNT 0.0f

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

#endif
