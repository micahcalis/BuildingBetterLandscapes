Shader "Beer/Geology"
{
    Properties
    {
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
            
            HLSLPROGRAM
            #pragma vertex VertBlitQuad
            #pragma fragment CrystalFrag

            #include "Assets/BBL/Shaders/ShaderIncludes/Passes/CrystalLandscape.hlsl"
            
            ENDHLSL
        }
    }
}