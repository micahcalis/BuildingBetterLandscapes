#ifndef FLUX_INCLUDED
#define FLUX_INCLUDED

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

#endif