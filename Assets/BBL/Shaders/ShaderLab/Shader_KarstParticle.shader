Shader "Beer/KarstParticle"
{
    Properties
    {
        [Header(Particle)]
        [Space]
        _SandColor("Sand Color", Color) = (0.5, 0.4, 0.4, 1)
        _ClayColor("Clay Color", Color) = (0.5, 0.4, 0.4, 1)
        _StoneColor("Stone Color", Color) = (0.5, 0.4, 0.4, 1)
        _FloorColor("Floor Color", Color) = (0.5, 0.5, 0.5, 1)
        [Header(Hologram)]
        _EmptyColor("Empty Color", Color) = (1, 0, 0, 0.2)
        _WaterColor("Water Color", Color) = (0, 0, 1, 0.2)
        _AcidColor("Acid Color", Color) = (1, 1, 0, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
        }
        
        Pass // 0
        {
            Name "Particle Color"
            
            HLSLPROGRAM
            #pragma vertex KarstParticleVert
            #pragma fragment KarstParticleFrag
            
            #pragma multi_compile_instancing

            #include "Assets/BBL/Shaders/ShaderIncludes/Karst/KarstParticlesInput.hlsl"
            #include "Assets/BBL/Shaders/ShaderIncludes/Karst/KarstParticlesPass.hlsl"

            ENDHLSL
        }

        Pass // 1
        {
            Name "Hologram Color"
            
            Tags
            {
                "RenderType" = "Transparent"
            }
            
            
            Blend SrcAlpha One 
            ZWrite Off
            Cull Off
            
            HLSLPROGRAM
            #pragma vertex KarstParticleVert
            #pragma fragment KarstHologramFrag
            
            #pragma multi_compile_instancing

            #include "Assets/BBL/Shaders/ShaderIncludes/Karst/KarstParticlesInput.hlsl"
            #include "Assets/BBL/Shaders/ShaderIncludes/Karst/KarstParticlesPass.hlsl"

            ENDHLSL
        }
    }
}