#ifndef FBM_INCLUDED
#define FBM_INCLUDED

struct FBM
{
    int depth;
    float frequency;
    float frequencyMultiplier;
    float amplitude;
    float amplitudeMultiplier;
};

FBM SetFbmData(int depth,
    float frequency,
    float frequencyMultiplier,
    float amplitude,
    float amplitudeMultiplier)
{
    FBM data;
    data.depth = depth;
    data.frequency = frequency;
    data.frequencyMultiplier = frequencyMultiplier;
    data.amplitude = amplitude;
    data.amplitudeMultiplier = amplitudeMultiplier;
    return data;
}

#endif