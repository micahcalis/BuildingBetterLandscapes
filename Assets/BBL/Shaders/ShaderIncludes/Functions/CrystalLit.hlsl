#ifndef CRYSTAL_LIT_INCLUDED
#define CRYSTAL_LIT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct CrystalLitInput
{
    float3 positionWS;
    float3 normalWS;
    float3 viewDirWS;
    float3 diffuse;
    float3 shadowColor;
    float shadowIntensity;
    float3 skyColor;
    float specularExp;
    float specularIntensity;
    float fresnelExp;
    float fresnelIntensity;
    Light light;
};

CrystalLitInput SetCrystalLitInput(float3 positionWS,
    float3 normalWS,
    float3 viewDirWS,
    float3 baseColor,
    float3 shadowColor,
    float shadowIntensity,
    float3 skyColor,
    float specularExp,
    float specularIntensity,
    float fresnelExp,
    float fresnelIntensity)
{
    CrystalLitInput input;
    input.positionWS = positionWS;
    input.normalWS = normalWS;
    input.viewDirWS = viewDirWS;
    input.diffuse = baseColor;
    input.shadowColor = shadowColor;
    input.shadowIntensity = shadowIntensity;
    input.skyColor = skyColor;
    input.specularExp = specularExp;
    input.specularIntensity = specularIntensity;
    input.fresnelExp = fresnelExp;
    input.fresnelIntensity = fresnelIntensity;
    input.light = GetMainLight();
    return input;
}

float3 GetAlbedo(CrystalLitInput input)
{
    float NdotL = saturate(dot(input.normalWS, input.light.direction));
    float attenuation = input.light.distanceAttenuation * input.light.shadowAttenuation;
    float shadowFactor = lerp(1.0 - input.shadowIntensity, 1.0, attenuation * NdotL);
    float3 directLight = lerp(input.shadowColor, input.light.color, shadowFactor);
    float3 directDiffuse = input.diffuse * directLight;
    float3 indirectDiffuse = input.diffuse * input.skyColor;
    return directDiffuse + indirectDiffuse * 0.5;
}

float3 GetSpecular(CrystalLitInput input)
{
    float3 halfVec = normalize(input.light.direction + input.viewDirWS);
    float NdotH = saturate(dot(input.normalWS, halfVec));
    float spec = pow(NdotH, input.specularExp);
    return spec * input.light.color;
}

float3 GetFresnel(CrystalLitInput input)
{
    float NdotV = 1 - saturate(dot(input.normalWS, -input.viewDirWS));
    float fresnel = pow(NdotV, input.fresnelExp) * input.fresnelIntensity;
    return fresnel * input.skyColor;
}

float3 CrystalLit(CrystalLitInput input)
{
    float3 albedo = GetAlbedo(input);
    float3 spec = GetSpecular(input);
    float3 fresnel = GetFresnel(input);
    return albedo + spec * input.specularIntensity + fresnel;
}

float3 GetSkyColor(float3 normalWS, float3 skyColor, float3 horizonColor, float gradExp)
{
    return lerp(horizonColor, skyColor, pow(saturate(normalWS.y), gradExp));
}

float3 GetTriplanar(Texture2D baseMap,
    SamplerState baseSampler,
    float blend,
    float3 positionWS,
    float3 normalWS,
    float tiling)
{
    float3 triPos = positionWS * tiling;
    float3 triBlend = pow(abs(normalWS), blend);

    float3 Node_X = SAMPLE_TEXTURE2D(baseMap, baseSampler, triPos.zy);
    float3 Node_Y = SAMPLE_TEXTURE2D(baseMap, baseSampler, triPos.xz);
    float3 Node_Z = SAMPLE_TEXTURE2D(baseMap, baseSampler, triPos.xy);
    float3 triColor = Node_X * triBlend.x + Node_Y * triBlend.y + Node_Z * triBlend.z;
    return triColor;
}

float3 UnpackNormalTriplanar(float4 sample, float strength)
{
    #if defined(UNITY_NO_DXT5nm)
        float3 normal = sample.rgb * 2.0 - 1.0;
    #else
        float3 normal;
        normal.xy = sample.wy * 2.0 - 1.0;
        normal.z = sqrt(max(1e-3, 1.0 - dot(normal.xy, normal.xy)));
    #endif

    normal.xy *= strength;
    return normalize(normal);
}

float3 GetTriplanarNormal(Texture2D normalMap,
    SamplerState normalSampler,
    float3 positionWS,
    float3 geometricNormal,
    float tiling,
    float blendSharpness,
    float normalStrength)
{
    float3 weights = abs(geometricNormal);
    weights = pow(weights, blendSharpness);
    weights = weights / (weights.x + weights.y + weights.z);

    float2 uvX = positionWS.zy * tiling;
    float2 uvY = positionWS.xz * tiling;
    float2 uvZ = positionWS.xy * tiling;

    float4 rawX = SAMPLE_TEXTURE2D(normalMap, normalSampler, uvX);
    float4 rawY = SAMPLE_TEXTURE2D(normalMap, normalSampler, uvY);
    float4 rawZ = SAMPLE_TEXTURE2D(normalMap, normalSampler, uvZ);

    float3 tNormalX = UnpackNormalTriplanar(rawX, normalStrength);
    float3 tNormalY = UnpackNormalTriplanar(rawY, normalStrength);
    float3 tNormalZ = UnpackNormalTriplanar(rawZ, normalStrength);
    
    float3 nX = float3(0, tNormalX.y, tNormalX.x); 
    float3 nY = float3(tNormalY.x, 0, tNormalY.y); 
    float3 nZ = float3(tNormalZ.x, tNormalZ.y, 0); 
    
    float3 worldNormal = normalize(
        geometricNormal + 
        nX * weights.x + 
        nY * weights.y + 
        nZ * weights.z
    );

    return worldNormal;
}

float GetAmbientOcclusion(float iterations, float maxSteps, float intensity, float contrast)
{
    float normalized = iterations / maxSteps;
    normalized = pow(normalized, contrast);
    return 1.0 - saturate(normalized * intensity);
}

#endif
