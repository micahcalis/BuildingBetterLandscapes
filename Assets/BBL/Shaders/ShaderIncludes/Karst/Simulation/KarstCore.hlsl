#ifndef KARST_CORE_INCLUDED
#define KARST_CORE_INCLUDED

#define NUM_MATS 4
#define FLOOR 0
#define STONE 1
#define CLAY 2
#define SAND 3

struct KarstMaterial
{
    int materialIndex;
    float density;
};

float3 _SimulationDimensions;

int GetMaterialIndex(float redChannel)
{
    return clamp(floor(redChannel * NUM_MATS), 0, NUM_MATS - 1);
}

float PackMaterialIndex(int materialIndex)
{
    return saturate((float)materialIndex / (float)(NUM_MATS - 1));
}

float3 GetUvw(uint3 id)
{
    return (float3)id / _SimulationDimensions;
}

bool ThreadOutOfBounds(uint3 id)
{
    return any(id >= (int3)_SimulationDimensions);
}

#endif