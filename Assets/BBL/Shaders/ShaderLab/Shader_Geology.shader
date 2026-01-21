Shader "Beer/Geology"
{
    Properties
    {
        [Header(Noise)]
        _NoiseIntensity("Noise Intensity", Float) = 1
        _CellDensity ("Cell Density", Float) = 1
        _AngleOffset ("Voronoi Angle", Float) = 1
        
        [Header(BRDF)]
        _BaseMap ("Main Texture", 2D) = "white" {}
        _TriBlend ("Triplanar Blend", Float) = 0.5
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Range(0, 5)) = 1
        _BaseColor("Base Color", Color) = (0.5, 0.5, 0.5, 1)
        _ShadowColor("Shadow Color", Color) = (0.2, 0.2, 0.4, 1)
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 1
        _SpecularExp("Specular Exponent", Range(0, 10)) = 1
        _SpecularIntensity("Specular Intensity", Range(0, 1)) = 1
        _AmbientOccExp("AO Exponent", Range(0, 10)) = 0.1
        _AmbientOccContrast("AO Contrast", Range(0, 10)) = 1
        _FresnelExp("Fresnel Exponent", Range(0, 10)) = 1
        _FresnelIntensity("Fresnel Intensity", Range(0, 1)) = 0.5
        
        [Header(Sky)]
        _SkyColor("Sky Color", Color) = (0.5, 0.6, 1, 1)
        _HorizonColor("Horizon Color", Color) = (0.8, 0.8, 0.8, 1)
        _SkyGradExp("Sky Gradient Exp", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
        }
        
        Pass
        {
            Name "Crystals Sphere Trace"
            
            ZTest Always
            
            HLSLPROGRAM
            #pragma vertex VertBlitQuad
            #pragma fragment CrystalFrag

            #include "Assets/BBL/Shaders/ShaderIncludes/Input/CrystalInput.hlsl"
            #include "Assets/BBL/Shaders/ShaderIncludes/Passes/CrystalLandscape.hlsl"
            
            ENDHLSL
        }
    }
}