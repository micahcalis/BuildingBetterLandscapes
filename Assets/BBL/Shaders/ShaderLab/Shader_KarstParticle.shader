Shader "Beer/KarstParticle"
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
            Name "Color"
            
            HLSLPROGRAM
            #pragma vertex KarstParticleVert
            #pragma fragment KarstParticleFrag
            
            #pragma multi_compile_instancing

            #include "Assets/BBL/Shaders/ShaderIncludes/Karst/KarstParticlesPass.hlsl"

            ENDHLSL
        }
    }
}