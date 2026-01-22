using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace BBL
{
    public class SphereTracingRenderFeature : ScriptableRendererFeature
    {
        private const RenderPassEvent SPHERE_TRACING_EVENT = RenderPassEvent.AfterRenderingPostProcessing;
        
        [SerializeField] private SphereTracingRenderSettings sphereTracingSettings;
        
        private CrystalTracingPass crystalTracingPass;
        
        public override void Create()
        {
            crystalTracingPass = new CrystalTracingPass(sphereTracingSettings, name);
            crystalTracingPass.renderPassEvent = SPHERE_TRACING_EVENT;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(crystalTracingPass);
        }

        protected override void Dispose(bool disposing)
        {
            crystalTracingPass.Dispose();
        }
    }

    [Serializable]
    public class SphereTracingRenderSettings
    {
        [field: Header("Settings"), Space]
        [field: SerializeField] public SphereTracingParams SphereTracingParams { get; private set; }
        
        [field: Header("References"), Space]
        [field: SerializeField] public Material SphereTracingMaterial { get; private set; }
        [field: SerializeField] public int PassIndex { get; private set; }
    }
}