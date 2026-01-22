using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace BBL
{
    public class CrystalTracingPass : ScriptableRenderPass
    {
        private SphereTracingRenderSettings sphereTracingSettings;
        private ProfilingSampler profilingSampler;
        private MaterialPropertyBlock propertyBlock;
        private MaterialPropertyCache cache = new();

        public CrystalTracingPass(SphereTracingRenderSettings sphereTracingSettings, string name)
        {
            this.sphereTracingSettings = sphereTracingSettings;
            profilingSampler = new ProfilingSampler(name);
            propertyBlock = new MaterialPropertyBlock();
        }
        
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (sphereTracingSettings.SphereTracingMaterial == null)
                return;
            
            CommandBuffer cmd = CommandBufferPool.Get("CrystalTracingPass");

            using (new ProfilingScope(cmd, profilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                
                sphereTracingSettings.SphereTracingParams.SetSphereTracingBlock(propertyBlock,
                    renderingData.cameraData.camera);
                
                SetTerrainBlock(propertyBlock);
                
                cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity,
                    sphereTracingSettings.SphereTracingMaterial,
                    submeshIndex: 0,
                    shaderPass: sphereTracingSettings.PassIndex,
                    propertyBlock);
            }
            
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public void SetTerrainBlock(MaterialPropertyBlock block)
        {
            Terrain targetTerrain = Terrain.activeTerrain;
            if (targetTerrain == null)
                return;
            
            block.SetVector(cache.Get("_TerrainPos"), targetTerrain.transform.position);
            block.SetVector(cache.Get("_TerrainSize"), targetTerrain.terrainData.size);
            block.SetTexture(cache.Get("_TerrainHeightMap"), targetTerrain.terrainData.heightmapTexture);
        }

        public void Dispose()
        {
            propertyBlock.Clear();
        }
    }
}