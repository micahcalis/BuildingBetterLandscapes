using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace BBL
{
    public class KarstSimulation
    {
        public RTHandle SimulationVolume;
        public bool Active { get; private set; } = false;
        
        private MaterialPropertyCache cache = new();

        public void Initialize(KarstSimSettings settings)
        {
            RenderTextureDescriptor descriptor = new RenderTextureDescriptor(settings.SimulationResolution.x,
                settings.SimulationResolution.y);
            descriptor.colorFormat = RenderTextureFormat.ARGB32;
            descriptor.depthBufferBits = 0;
            descriptor.enableRandomWrite = true;
            descriptor.dimension = TextureDimension.Tex3D;
            descriptor.volumeDepth = settings.SimulationResolution.z;
            
            RenderingUtils.ReAllocateIfNeeded(ref SimulationVolume, descriptor);
            Debug.Log("SimulationRes: " + SimulationVolume.rt.width + ", " + 
                      SimulationVolume.rt.height + ", " + 
                      SimulationVolume.rt.volumeDepth);

            Fill(settings);
        }

        public void Dispose()
        {
            SimulationVolume?.Release();
        }

        public void SetActive(bool active)
        {
            Active = active;
        }

        private void Fill(KarstSimSettings settings)
        {
            ComputeShader compute = settings.KarstSimCompute;
            int kernel = KarstSimSettings.FILL_KERNEL;
            Vector3Int groups = KarstSimUtilities.GetThreadGroupsFull(SimulationVolume.rt, KarstSimSettings.THREADGROUP_SIZE);
            
            compute.SetTexture(kernel, cache.Get("_FillTarget"), SimulationVolume);
            compute.SetFloat(cache.Get("_FloorAmount"), settings.FloorAmount);
            compute.SetFloat(cache.Get("_StoneAmount"), settings.StoneAmount);
            compute.SetFloat(cache.Get("_ClayAmount"), settings.ClayAmount);
            compute.SetFloat(cache.Get("_SandAmount"), settings.SandAmount);
            compute.SetVector(cache.Get("_SimulationDimensions"), (Vector3)settings.SimulationResolution);
            compute.SetFloat(cache.Get("_KarstLayerNoiseScale"), 1.0f / settings.LayerNoiseScale);
            compute.SetInt(cache.Get("_KarstLayerNoiseSeed"), settings.LayerNoiseSeed);
            compute.SetInt(cache.Get("_KarstLayerNoiseOctaves"), settings.LayerNoiseOctaves);
            
            compute.Dispatch(kernel, groups.x, groups.y, groups.z);
        }
    }
}