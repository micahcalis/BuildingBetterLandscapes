using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace BBL
{
    public class KarstSimulation
    {
        public RTHandle SimulationVolume;
        public ComputeBuffer FluxBuffer;
        public bool Active { get; private set; } = false;
        
        private MaterialPropertyCache cache = new();

        public void Initialize(KarstSimSettings settings)
        {
            RenderTextureDescriptor descriptor = new RenderTextureDescriptor(settings.SimulationResolution.x,
                settings.SimulationResolution.y);
            descriptor.colorFormat = RenderTextureFormat.ARGBFloat;
            descriptor.depthBufferBits = 0;
            descriptor.enableRandomWrite = true;
            descriptor.dimension = TextureDimension.Tex3D;
            descriptor.volumeDepth = settings.SimulationResolution.z;
            
            RenderingUtils.ReAllocateIfNeeded(ref SimulationVolume, descriptor);
            Debug.Log("SimulationRes: " + SimulationVolume.rt.width + ", " + 
                      SimulationVolume.rt.height + ", " + 
                      SimulationVolume.rt.volumeDepth);

            FluxBuffer = new ComputeBuffer(settings.GetVoxelCount(), 
                Marshal.SizeOf(typeof(Flux)),
                ComputeBufferType.Structured);
        }

        public void Dispose()
        {
            SimulationVolume?.Release();
            FluxBuffer?.Release();
        }

        public void SetActive(bool active)
        {
            Active = active;
        }

        public void Fill(KarstSimSettings settings)
        {
            ComputeShader compute = settings.KarstSimCompute;
            int kernel = KarstSimSettings.FILL_KERNEL;
            Vector3Int groups = KarstSimUtilities.GetThreadGroupsFull(SimulationVolume.rt, 
                KarstSimSettings.THREADGROUP_SIZE_S);
            
            compute.SetTexture(kernel, cache.Get("_FillTarget"), SimulationVolume);
            compute.SetFloat(cache.Get("_FloorAmount"), settings.FloorAmount);
            compute.SetFloat(cache.Get("_StoneAmount"), settings.StoneAmount);
            compute.SetFloat(cache.Get("_ClayAmount"), settings.ClayAmount);
            compute.SetFloat(cache.Get("_SandAmount"), settings.SandAmount);
            compute.SetVector(cache.Get("_SimulationDimensions"), (Vector3)settings.SimulationResolution);
            compute.SetFloat(cache.Get("_KarstLayerNoiseScale"), settings.LayerNoiseScale);
            compute.SetInt(cache.Get("_KarstLayerNoiseSeed"), settings.LayerNoiseSeed);
            compute.SetInt(cache.Get("_KarstLayerNoiseOctaves"), settings.LayerNoiseOctaves);
            
            compute.Dispatch(kernel, groups.x, groups.y, groups.z);
        }

        public void Fracture(KarstSimSettings settings)
        {
            ComputeShader compute = settings.KarstSimCompute;
            int kernel = KarstSimSettings.FRACTURE_KERNEL;
            Vector3Int groups = KarstSimUtilities.GetThreadGroupsFull(SimulationVolume.rt, 
                KarstSimSettings.THREADGROUP_SIZE_S);
            
            compute.SetTexture(kernel, cache.Get("_FractureTarget"), SimulationVolume);
            compute.SetFloat(cache.Get("_FloorAmount"), settings.FloorAmount);
            compute.SetFloat(cache.Get("_StoneAmount"), settings.StoneAmount);
            compute.SetVector(cache.Get("_SimulationDimensions"), (Vector3)settings.SimulationResolution);
            compute.SetFloat(cache.Get("_KarstFractureNoiseScale"), settings.FractureNoiseScale);
            compute.SetFloat(cache.Get("_KarstFractureNoiseAngle"), settings.FractureAngle);
            compute.SetInt(cache.Get("_KarstFractureNoiseSeed"), settings.FractureNoiseSeed);
            compute.SetFloat(cache.Get("_KarstFractureZoom"), settings.FractureZoom);
            
            compute.Dispatch(kernel, groups.x, groups.y, groups.z);
        }

        public void ClearFlux(KarstSimSettings settings)
        {
            ComputeShader compute = settings.FluxClearCompute;
            int kernel = KarstSimSettings.CLEAR_FLUX_KERNEL;
            int groupSize = KarstSimUtilities.GetThreadGroups1D(settings.GetVoxelCount(), 
                KarstSimSettings.THREADGROUP_SIZE_L);
            
            compute.SetBuffer(kernel, cache.Get("_FluxBuffer"), FluxBuffer);
            compute.SetInt(cache.Get("_MaxVoxels"), settings.GetVoxelCount());
            
            compute.Dispatch(kernel, groupSize, 1, 1);
        }

        public void MargolusSwap(KarstSimSettings settings, bool isEven)
        {
            ComputeShader compute = settings.KarstSimCompute;
            int kernel = KarstSimSettings.MARGOLUS_KERNEL;
            Vector3Int groupSize = KarstSimUtilities.GetThreadGroupsFull(SimulationVolume.rt, 
                KarstSimSettings.THREADGROUP_SIZE_S);
            
            compute.SetTexture(kernel, cache.Get("_MargolusTarget"), SimulationVolume);
            compute.SetInt(cache.Get("_MargolusIsEven"), isEven ? 0 : 1);
            compute.SetVector(cache.Get("_SimulationDimensions"), (Vector3)settings.SimulationResolution);
            
            compute.Dispatch(kernel, groupSize.x, groupSize.y, groupSize.z);
        }

        public void InjectWater(KarstSimSettings settings, float deltaTime)
        {
            ComputeShader compute = settings.KarstSimCompute;
            int kernel = KarstSimSettings.INJECT_WATER_KERNEL;
            Vector3Int groupSize = KarstSimUtilities.GetThreadGroupsFull(SimulationVolume.rt,
                KarstSimSettings.THREADGROUP_SIZE_S);
            
            compute.SetTexture(kernel, cache.Get("_InjectTarget"), SimulationVolume);
            compute.SetVector(cache.Get("_SimulationDimensions"), (Vector3)settings.SimulationResolution);
            compute.SetFloat(cache.Get("_DeltaTime"), deltaTime);
            compute.SetFloat(cache.Get("_WaterInjectRate"), settings.WaterInjectRate);
            compute.SetFloat(cache.Get("_WaterPermThreshold"), settings.PermeableThreshold);
            compute.SetFloat(cache.Get("_FloorAmount"), settings.FloorAmount);
            compute.SetFloat(cache.Get("_StoneAmount"), settings.StoneAmount);
            
            compute.Dispatch(kernel, groupSize.x, groupSize.y, groupSize.z);
        }

        public void CalculateFlux(KarstSimSettings settings, float deltaTime)
        {
            ComputeShader compute = settings.KarstSimCompute;
            int kernel = KarstSimSettings.CALC_FLUX_KERNEL;
            Vector3Int groupSize = KarstSimUtilities.GetThreadGroupsFull(SimulationVolume.rt,
                KarstSimSettings.THREADGROUP_SIZE_S);
            
            compute.SetTexture(kernel, cache.Get("_FluxSource"), SimulationVolume);
            compute.SetBuffer(kernel, cache.Get("_FluxBuffer"), FluxBuffer);
            compute.SetVector(cache.Get("_SimulationDimensions"), (Vector3)settings.SimulationResolution);
            compute.SetFloat(cache.Get("_DeltaTime"), deltaTime);
            
            compute.Dispatch(kernel, groupSize.x, groupSize.y, groupSize.z);
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct Flux
    {
        public float Right;
        public float Left;
        public float Up;
        public float Down;
        public float Front;
        public float Back;
    }
}