#ifndef VORONOI_FUNCTIONS_INCLUDED
#define VORONOI_FUNCTIONS_INCLUDED

struct Voronoi
{
    float distance;
    float id;
};

float2 RandomVector(float2 uv, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    uv = frac(sin(mul(uv, m)) * 46839.32);
    return float2(sin(uv.y*+offset)*0.5+0.5, cos(uv.x*offset)*0.5+0.5);
}

Voronoi Voronoi2D(float2 uv, float angleOffset, float cellDensity)
{
    Voronoi output = (Voronoi)0;
    float2 g = floor(uv * cellDensity);
    float2 f = frac(uv * cellDensity);
    float3 res = float3(8.0, 0.0, 0.0);

    for(int y=-1; y<=1; y++)
    {
        for(int x=-1; x<=1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = RandomVector(lattice + g, angleOffset);
            float d = distance(lattice + offset, f);
            if(d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                output.distance = res.x;
                output.id = res.y;
            }
        }
    }

    return output;
}

#endif