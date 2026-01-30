#ifndef FLUX_INCLUDED
#define FLUX_INCLUDED

#define F_DIR_R int3(1, 0, 0)
#define F_DIR_L int3(-1, 0, 0)
#define F_DIR_U int3(0, 1, 0)
#define F_DIR_D int3(0, -1, 0)
#define F_DIR_F int3(0, 0, 1)
#define F_DIR_B int3(0, 0, -1)
#define F_DIR_COUNT 6

static const int3 FLUX_DIRS[F_DIR_COUNT] = 
{
    F_DIR_R,
    F_DIR_L, 
    F_DIR_U,
    F_DIR_D,
    F_DIR_F,
    F_DIR_B
};

struct Flux
{
    float right;
    float left;
    float up;
    float down;
    float front;
    float back;
};

RWStructuredBuffer<Flux> _FluxBuffer;

int Flatten(uint3 id, float3 dim)
{
    return id.x + (id.y * dim.x) + (id.z * dim.x * dim.y);
}

uint3 Unflatten(uint index, float3 dim)
{
    uint x = index % dim.x;
    uint y = (index / dim.x) % dim.y;
    uint z = index / (dim.x * dim.y);
    return uint3(x, y, z);
}

Flux GetFlux(uint3 id, float3 dim)
{
    int index = Flatten(id, dim);
    return _FluxBuffer[index];
}

void SetFlux(Flux flux, uint3 id, float3 dim)
{
    int index = Flatten(id, dim);
    _FluxBuffer[index] = flux;
}

void SetFluxValByIndex(int i, float val, inout Flux flux)
{
    if (i == 0) flux.right = val;
    else if (i == 1) flux.left = val;
    else if (i == 2) flux.up = val;
    else if (i == 3) flux.down = val;
    else if (i == 4) flux.front = val;
    else if (i == 5) flux.back = val;
}

float GetFluxValByIndex(int i, Flux flux)
{
    if (i == 0) return flux.right;
    else if (i == 1) return flux.left;
    else if (i == 2) return flux.up;
    else if (i == 3) return flux.down;
    else if (i == 4) return flux.front;
    else if (i == 5) return flux.back;
    return 0;
}

float SumFlux(Flux flux)
{
    float sum = 0;
    [unroll(F_DIR_COUNT)]
    for (int i = 0; i < F_DIR_COUNT; i++)
    {
        sum += GetFluxValByIndex(i, flux);
    }
    return sum;
}

void ScaleFlux(float scale, inout Flux flux)
{
    [unroll(F_DIR_COUNT)]
    for (int i = 0; i < F_DIR_COUNT; i++)
    {
        float scaledFlux = GetFluxValByIndex(i, flux) * scale;
        SetFluxValByIndex(i, scaledFlux, flux);
    }
}

// AI generated
int GetOppositeIndex(int i)
{
    // 0(R) <-> 1(L)
    // 2(U) <-> 3(D)
    // 4(F) <-> 5(B)
    return i ^ 1; 
}

#endif