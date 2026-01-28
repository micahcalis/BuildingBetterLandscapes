using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;

namespace BBL
{
    public class RenderKarstParticlesPass : ScriptableRenderPass
    {
        private const int PARTICLE_PASS = 0;
        private const int HOLOGRAM_PASS = 1;
        
        private KarstSimSettings settings;
        private KarstSimulation simulation => KarstSimController.Simulation;
        private ProfilingSampler profilingSampler;
        private ComputeBuffer karstParticlesBuffer;
        private ComputeBuffer drawBuffer;
        private MaterialPropertyCache cache = new();
        MaterialPropertyBlock propertyBlock = new();
        private int maxParticles;
        
        public RenderKarstParticlesPass(KarstSimSettings settings, string name)
        {
            this.settings = settings;
            profilingSampler = new ProfilingSampler(name);
        }
        
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (settings.ParticleMesh == null || settings.ParticleMaterial == null)
                return;
            
            if (simulation == null)
                return;

            if (!simulation.Active)
                return;
            
            CommandBuffer cmd = CommandBufferPool.Get("Render Karst Particles");

            using (new ProfilingScope(cmd, profilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                
                ExtractParticles(cmd, out bool appendMode);
                CopyAppendCount(cmd);
                FillMaterialBlock();
                
                cmd.DrawMeshInstancedIndirect(settings.ParticleMesh,
                    submeshIndex: 0,
                    settings.ParticleMaterial,
                    shaderPass: appendMode ? PARTICLE_PASS : HOLOGRAM_PASS,
                    drawBuffer,
                    argsOffset: 0,
                    properties: propertyBlock);
            }
            
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        private void ExtractParticles(CommandBuffer cmd, out bool appendMode)
        {
            ComputeShader compute = settings.KarstExtractCompute;
            int kernel = KarstSimSettings.EXTRACT_KERNEL;
            Vector3Int groups = KarstSimUtilities.GetThreadGroupsFull(simulation.SimulationVolume.rt, KarstSimSettings.THREADGROUP_SIZE);

            if (NewBuffer())
            {
                karstParticlesBuffer?.Release();
                karstParticlesBuffer = new ComputeBuffer(maxParticles, Marshal.SizeOf(typeof(KarstParticle)),
                    ComputeBufferType.Append);
            }
            
            cmd.SetBufferCounterValue(karstParticlesBuffer, 0);

            cmd.SetComputeBufferParam(compute, kernel, cache.Get("_KarstParticlesAppendBuffer"), karstParticlesBuffer);
            cmd.SetComputeTextureParam(compute, kernel, cache.Get("_KarstVolume"), simulation.SimulationVolume);
            cmd.SetComputeMatrixParam(compute, cache.Get("_ParticleToWorld"), GetKarstParticleToWorldMatrix());
            cmd.SetComputeVectorParam(compute, cache.Get("_SimulationDimensions"), (Vector3)settings.SimulationResolution);
            appendMode = settings.ViewMode == KarstViewMode.Particles;
            cmd.SetComputeIntParam(compute, cache.Get("_AppendMode"), appendMode ? 0 : 1);
            
            cmd.DispatchCompute(compute, kernel, groups.x, groups.y, groups.z);
        }

        private void CopyAppendCount(CommandBuffer cmd)
        {
            if (drawBuffer == null || !drawBuffer.IsValid())
            {
                drawBuffer?.Release();
                drawBuffer = new ComputeBuffer(1, 5 * sizeof(uint), ComputeBufferType.IndirectArguments);
            }

            Mesh mesh = settings.ParticleMesh;
            
            uint[] args = new uint[5];
            args[0] = mesh.GetIndexCount(0);
            args[1] = 0;
            args[2] = mesh.GetIndexStart(0);
            args[3] = mesh.GetBaseVertex(0);
            args[4] = 0;
            
            drawBuffer.SetData(args);
            cmd.CopyCounterValue(karstParticlesBuffer, drawBuffer, sizeof(uint));
        }

        private void FillMaterialBlock()
        {
            propertyBlock.SetBuffer(cache.Get("_ParticleBuffer"), karstParticlesBuffer);
            propertyBlock.SetMatrix(cache.Get("_ParticleToWorld"), GetKarstParticleToWorldMatrix());
        }

        public void Dispose()
        {
            karstParticlesBuffer?.Release();
            drawBuffer?.Release();
        }

        private bool NewBuffer()
        {
            int currentMaxParticles = settings.SimulationResolution.x * settings.SimulationResolution.y * settings.SimulationResolution.z;

            if (currentMaxParticles != maxParticles)
            {
                maxParticles = currentMaxParticles;
                return true;
            }

            return karstParticlesBuffer == null || !karstParticlesBuffer.IsValid();
        }

        private Matrix4x4 GetKarstParticleToWorldMatrix()
        {
            return Matrix4x4.TRS(settings.SimulationCenter,
                Quaternion.identity,
                settings.ParticleSize * Vector3.one);
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct KarstParticle
    {
        public Vector3 LocalPos;
        public int MaterialIndex;
        public float Density;
    }
}