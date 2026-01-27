using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace BBL
{
    public class KarstSimulation
    {
        public RTHandle SimulationVolume;

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
            Debug.Log("SimulationRes: " + SimulationVolume.rt.width + ", " + SimulationVolume.rt.height);
        }

        public void Update()
        {
            
        }

        public void Dispose()
        {
            SimulationVolume?.Release();
        }
    }
}