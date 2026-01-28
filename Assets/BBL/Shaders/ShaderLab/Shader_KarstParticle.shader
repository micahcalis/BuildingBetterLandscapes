Shader "Beer/KarstParticle"
{
    Properties
    {
        _SandColor("Sand Color", Color) = (0.5, 0.4, 0.4, 1)
        _ClayColor("Clay Color", Color) = (0.5, 0.4, 0.4, 1)
        _StoneColor("Stone Color", Color) = (0.5, 0.4, 0.4, 1)
        _FloorColor("Floor Color", Color) = (0.5, 0.5, 0.5, 1)
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

            #include "Assets/BBL/Shaders/ShaderIncludes/Karst/KarstParticlesInput.hlsl"
            #include "Assets/BBL/Shaders/ShaderIncludes/Karst/KarstParticlesPass.hlsl"

            ENDHLSL
        }
    }
}