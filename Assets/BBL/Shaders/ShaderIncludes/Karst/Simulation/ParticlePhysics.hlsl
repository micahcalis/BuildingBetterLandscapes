#ifndef PARTICLE_PHSYICS_INCLUDED
#define PARTICLE_PHSYICS_INCLUDED

#define DIR_LB 0, 0
#define DIR_RB 1, 0
#define DIR_LF 0, 1
#define DIR_RF 1, 1
#define DIR_COUNT 4

static const int2 MARG_DIRS[DIR_COUNT] = 
{
    int2(DIR_LB),
    int2(DIR_RB), 
    int2(DIR_LF),
    int2(DIR_RF)
};

struct MaterialPair
{
    int materialIndex;
    float density;
};

struct MargolusRow
{
    MaterialPair LeftBack;
    MaterialPair RightBack;
    MaterialPair LeftFront;
    MaterialPair RightFront;
};

int _MargolusIsEven;

bool GetMargolusBaseId(uint3 id, out uint3 baseId)
{
    baseId = id * 2 + (uint3)_MargolusIsEven;
    return !ThreadOutOfBounds(baseId);
}

int3 GetMargolusCoord(int3 base, int2 dir, bool top)
{
    int3 rawCoord = base + int3(dir.x, top ? 1 : 0, dir.y);
    return clamp(rawCoord, 0, uint3(_SimulationDimensions - 1));
}

void SetPairByIndex(int i, MaterialPair pair, inout MargolusRow row)
{
    if (i == 0) row.LeftBack = pair;
    else if (i == 1) row.RightBack = pair;
    else if (i == 2) row.LeftFront = pair;
    else if (i == 3) row.RightFront = pair;
}

MaterialPair GetPairByIndex(int i, MargolusRow row)
{
    if (i == 0) return row.LeftBack;
    else if (i == 1) return row.RightBack;
    else if (i == 2) return row.LeftFront;
    else if (i == 3) return row.RightFront;
    return (MaterialPair)0;
}

void GetMargolusRows(uint3 baseId, RWTexture3D<float4> margolusTarget,
    out MargolusRow topRow, out MargolusRow bottomRow)
{
    topRow = (MargolusRow)0;
    bottomRow = (MargolusRow)0;
    
    [unroll(DIR_COUNT)]
    for (int i = 0; i < DIR_COUNT; i++)
    {
        int2 dir = MARG_DIRS[i];
        float4 valTop = margolusTarget[GetMargolusCoord(baseId, dir, true)];
        float4 valBottom = margolusTarget[GetMargolusCoord(baseId, dir, false)];

        MaterialPair pairTop;
        pairTop.materialIndex = GetMaterialIndex(valTop.r);
        pairTop.density = valTop.g;

        MaterialPair pairBottom;
        pairBottom.materialIndex = GetMaterialIndex(valBottom.r);
        pairBottom.density = valBottom.g;
        
        SetPairByIndex(i, pairTop, topRow);
        SetPairByIndex(i, pairBottom, bottomRow);
    }
}

void TrySwap(inout MaterialPair a, inout MaterialPair b)
{
    if (a.materialIndex == SAND && IsAir(b.density))
    {
        MaterialPair temp = a;
        a = b;
        b = temp;
    }
}

void ApplyVerticalGravity(inout MargolusRow top, inout MargolusRow bot)
{
    TrySwap(top.LeftBack, bot.LeftBack);
    TrySwap(top.RightBack, bot.RightBack);  
    TrySwap(top.LeftFront, bot.LeftFront);  
    TrySwap(top.RightFront, bot.RightFront);
}

void ApplyHorizontalSlopes(inout MargolusRow top, inout MargolusRow bot)
{
    TrySwap(top.LeftBack, bot.LeftFront);
    TrySwap(top.RightBack, bot.RightFront);
    TrySwap(top.LeftFront, bot.LeftBack);
    TrySwap(top.RightFront, bot.RightBack);
    
    TrySwap(top.LeftBack, bot.RightBack);
    TrySwap(top.RightBack, bot.LeftBack);
    TrySwap(top.LeftFront, bot.RightFront);
    TrySwap(top.RightFront, bot.LeftFront);
}

void ApplyDiagonalSlopes(inout MargolusRow top, inout MargolusRow bot)
{
    TrySwap(top.LeftBack, bot.RightFront);
    TrySwap(top.RightBack, bot.LeftFront);
    TrySwap(top.LeftFront, bot.RightBack);
    TrySwap(top.RightFront, bot.LeftBack);
}

void ResolvePair(MaterialPair pair, RWTexture3D<float4> margolusTarget, int3 coord)
{
    float4 sample = margolusTarget[coord];
    margolusTarget[coord] = float4(float2(PackMaterialIndex(pair.materialIndex), pair.density),
        sample.b, sample.a);
}

void ResolveMargolusRows(uint3 baseId, RWTexture3D<float4> margolusTarget,
    MargolusRow topRow, MargolusRow bottomRow)
{
    [unroll(DIR_COUNT)]
    for (int i = 0; i < DIR_COUNT; i++)
    {
        MaterialPair pairTop = GetPairByIndex(i, topRow);
        MaterialPair pairBottom = GetPairByIndex(i, bottomRow);

        int2 dir = MARG_DIRS[i];
        ResolvePair(pairTop, margolusTarget, GetMargolusCoord(baseId, dir, true));
        ResolvePair(pairBottom, margolusTarget, GetMargolusCoord(baseId, dir, false));
    }
}

#endif