using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace BBL
{
    public class KarstSimRenderFeature : ScriptableRendererFeature
    {
        private const RenderPassEvent RENDER_EVENT = RenderPassEvent.AfterRenderingOpaques;
        
        [field: SerializeField] public KarstSimSettings KarstSimSettings { get; private set; }
        
        private KarstSimController karstSimController;
        private KarstEventHandler karstEventHandler;
        private RenderKarstParticlesPass renderKarstParticlesPass;
        private bool simulationInitialized = false;
        
        public override void Create()
        {
            renderKarstParticlesPass = new RenderKarstParticlesPass(KarstSimSettings, name);
            renderKarstParticlesPass.renderPassEvent = RENDER_EVENT;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (Application.isPlaying)
            {
                if (!simulationInitialized)
                {
                    InitializeEventHandler();
                    InitializeSimController();
                    simulationInitialized = true;
                }

                if (renderKarstParticlesPass != null)
                {
                    renderer.EnqueuePass(renderKarstParticlesPass);
                }
            }
        }

        protected override void Dispose(bool disposing)
        {
            renderKarstParticlesPass?.Dispose();
            DestroySimulation();
        }

        private void InitializeEventHandler()
        {
            karstEventHandler = FindObjectOfType<KarstEventHandler>();

            if (karstEventHandler == null)
                karstEventHandler = GetEventHandler();
            
            if(karstEventHandler != null)
                karstEventHandler.Initialize(KarstSimSettings);
        }

        private void InitializeSimController()
        {
            karstSimController = new KarstSimController(KarstSimSettings);
            
            if(karstEventHandler != null)
            {
                karstEventHandler.OnSimStart += karstSimController.StartSimulation;
                karstEventHandler.OnSimEnd += karstSimController.EndSimulation;
            }
        }

        private void DestroySimulation()
        {
            if (karstEventHandler != null)
            {
                if(Application.isPlaying)
                    Destroy(karstEventHandler.gameObject);
                else
                    DestroyImmediate(karstEventHandler.gameObject);
            }
            
            karstEventHandler = null;
            
            karstSimController?.Dispose();
            karstSimController = null;
            
            simulationInitialized = false;
        }

        private KarstEventHandler GetEventHandler()
        {
            GameObject handlerObject = new GameObject(typeof(KarstEventHandler).ToString());
            return handlerObject.AddComponent<KarstEventHandler>();
        }
    }

    [Serializable]
    public class KarstSimSettings
    {
        public static readonly int FILL_KERNEL = 0;
        public static readonly int EXTRACT_KERNEL = 0;
        public static int THREADGROUP_SIZE = 8;
        
        [field: Header("Simulation Settings"), Space]
        [field: SerializeField] public Vector3 SimulationCenter { get; private set; }
        [field: SerializeField] public float ParticleSize { get; private set; } = 1;
        
        [field: Header("References"), Space]
        [field: SerializeField] public GameObject UserIntPrefab { get; private set; }
        [field: SerializeField] public ComputeShader KarstSimCompute { get; private set; }
        [field: SerializeField] public ComputeShader KarstExtractCompute { get; private set; }
        [field: SerializeField] public Material ParticleMaterial { get; private set; }
        [field: SerializeField] public Mesh ParticleMesh { get; private set; }
        
        public Vector3Int SimulationResolution { get; set; }
    }
}