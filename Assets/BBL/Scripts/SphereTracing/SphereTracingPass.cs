using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace BBL
{
    public class SphereTracingPass : ScriptableRenderPass
    {
        private SphereTracingRenderSettings sphereTracingSettings;
        private ProfilingSampler profilingSampler;
        private MaterialPropertyBlock propertyBlock;

        public SphereTracingPass(SphereTracingRenderSettings sphereTracingSettings, string name)
        {
            this.sphereTracingSettings = sphereTracingSettings;
            profilingSampler = new ProfilingSampler(name);
            propertyBlock = new MaterialPropertyBlock();
        }
        
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (sphereTracingSettings.SphereTracingMaterial == null)
                return;
            
            CommandBuffer cmd = CommandBufferPool.Get("SphereTracingPass");

            using (new ProfilingScope(cmd, profilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                
                sphereTracingSettings.SphereTracingParams.SetSphereTracingBlock(propertyBlock,
                    renderingData.cameraData.camera);
                
                cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity,
                    sphereTracingSettings.SphereTracingMaterial,
                    submeshIndex: 0,
                    shaderPass: sphereTracingSettings.PassIndex,
                    propertyBlock);
            }
            
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public void Dispose()
        {
            propertyBlock.Clear();
        }
    }
}