#ifndef KARST_NOISE_INCLUDED
#define KARST_NOISE_INCLUDED

#include "Assets/BBL/Shaders/ShaderIncludes/Library/FBM.hlsl"

#define LAYER_N_STRENGTH 0.15f
#define LAYER_N_F_MUL 1.15f
#define LAYER_N_A_MUL 0.95f

#define FRAC_N_L_STRENGTH 0.15f
#define FRAC_N_H_STRENGTH 0.05f
#define FRAC_F_MUL 0.33f
#define FRAC_EDGE 0.5
#define FRAC_CONTRAST 6.0f

struct Fracture
{
    float density;
    float height;
};

float _KarstLayerNoiseScale;
int _KarstLayerNoiseSeed;
int _KarstLayerNoiseOctaves;

float _KarstFractureNoiseScale;
float _KarstFractureNoiseAngle;
int _KarstFractureNoiseSeed;
float _KarstFractureZoom;

// from unity shader graph: https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Gradient-Noise-Node.html
float2 RandomVector2D(float2 pos)
{
    pos = pos % 289;
    float x = (34 * pos.x + 1) * pos.x % 289 + pos.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float Perlin2D(float2 pos)
{
    float2 ip = floor(pos);
    float2 fp = frac(pos);
    float d00 = dot(RandomVector2D(ip), fp);
    float d01 = dot(RandomVector2D(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(RandomVector2D(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(RandomVector2D(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float Perlin2D01(float2 pos)
{
    return Perlin2D(pos) * 0.5 + 0.5;
}

uint Hash11(uint n)
{
    // Integer hash copied from Hugo Elias
    n = (n << 13u) ^ n;
    n = n * (n * n * 15731u + 789221u) + 1376312589u;
    return n;
}

float HashToFloat(uint n)
{
    return float(n) * (1.0 / 4294967295.0);
}

float FbmPerlin2D(float2 coord, FBM fbm)
{
    float amplitude = fbm.amplitude;
    float frequency = fbm.frequency;
    float noise = 0;
    float amplitudeSum = 1e-4;

    for (int i = 0; i < fbm.depth; i++)
    {
        noise += amplitude * Perlin2D(coord * frequency);
        amplitudeSum += amplitude;

        amplitude *= fbm.amplitudeMultiplier;
        frequency *= fbm.frequencyMultiplier;
    }

    return noise / amplitudeSum;
}

float GetLayerNoise(float2 uv, int materialIndex)
{
    uint baseSeed = _KarstLayerNoiseSeed + (uint)materialIndex;
    
    float2 randomOffset = float2(HashToFloat(Hash11(baseSeed)), 
        HashToFloat(Hash11(baseSeed + 196))) * 100.0f;
    
    float2 coord = uv + randomOffset;
    
    FBM fbm = SetFbmData(_KarstLayerNoiseOctaves,
        _KarstLayerNoiseScale,
        LAYER_N_F_MUL,
        1.0f,
        LAYER_N_A_MUL);

    float noise = FbmPerlin2D(coord, fbm);
    return noise * LAYER_N_STRENGTH;
}

float2 RotateCenter2D(float2 uv, float2 center, float angle)
{
    uv -= center;
    float s = sin(angle);
    float c = cos(angle);
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix * 2 - 1;
    uv.xy = mul(uv.xy, rMatrix);
    uv += center;
    return uv;
}

float2 GetOffsetCoord(float2 uv, out float offsetNoiseHigh)
{
    float noiseLowScale = _KarstFractureNoiseScale;
    float noiseHighScale = noiseLowScale * FRAC_F_MUL;
    float2 seedCoord = uv + HashToFloat(Hash11(_KarstFractureNoiseSeed)) * 100;

    float offsetNoiseLow = Perlin2D01(seedCoord * noiseLowScale) * FRAC_N_L_STRENGTH;
    offsetNoiseHigh = Perlin2D01(seedCoord * noiseHighScale) * FRAC_N_H_STRENGTH;
    float2 noiseCoord = seedCoord + offsetNoiseLow + offsetNoiseHigh;
    float2 rotateCoord = RotateCenter2D(noiseCoord, 0, _KarstFractureNoiseAngle);

    return rotateCoord;
}

Fracture GetFractureNoise(float2 uv)
{
    float heightNoise;
    float2 offsetCoord = GetOffsetCoord(uv, heightNoise);
    float2 fractureCoord = offsetCoord * _KarstFractureZoom;
    float2 horizontalCoord = fractureCoord.xx;
    float2 verticalCoord = fractureCoord.yy;
    
    float horizontalFracture = Perlin2D01(horizontalCoord);
    float verticalFracture = Perlin2D01(verticalCoord);
    float densityRaw = min(horizontalFracture, verticalFracture);
    float density = pow(smoothstep(0, FRAC_EDGE, densityRaw), FRAC_CONTRAST);

    Fracture fracture;
    fracture.density = density;
    fracture.height = ((heightNoise / FRAC_N_L_STRENGTH)) * 3;
    return fracture;
}

#endif