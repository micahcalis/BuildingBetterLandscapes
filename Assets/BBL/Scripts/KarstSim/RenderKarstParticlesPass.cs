using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;

namespace BBL
{
    public class RenderKarstParticlesPass : ScriptableRenderPass
    {
        private KarstSimSettings settings;
        private KarstSimulation simulation => KarstSimController.Simulation;
        private ProfilingSampler profilingSampler;
        
        public RenderKarstParticlesPass(KarstSimSettings settings, string name)
        {
            this.settings = settings;
            profilingSampler = new ProfilingSampler(name);
        }
        
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
 
        }

        public void Dispose()
        {
            
        }
    }
}