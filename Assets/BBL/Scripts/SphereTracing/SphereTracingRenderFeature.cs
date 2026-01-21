using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace BBL
{
    public class SphereTracingRenderFeature : ScriptableRendererFeature
    {
        private const RenderPassEvent SPHERE_TRACING_EVENT = RenderPassEvent.AfterRenderingPostProcessing;
        
        [SerializeField] private SphereTracingRenderSettings sphereTracingSettings;
        
        private SphereTracingPass sphereTracingPass;
        
        public override void Create()
        {
            sphereTracingPass = new SphereTracingPass(sphereTracingSettings, name);
            sphereTracingPass.renderPassEvent = SPHERE_TRACING_EVENT;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(sphereTracingPass);
        }

        protected override void Dispose(bool disposing)
        {
            sphereTracingPass.Dispose();
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