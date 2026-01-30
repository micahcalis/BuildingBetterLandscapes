using UnityEngine;
using System;

namespace BBL
{
    [Serializable]
    public class KarstSimSettings
    {
        public static readonly int FILL_KERNEL = 0;
        public static readonly int FRACTURE_KERNEL = 1;
        public static readonly int EXTRACT_KERNEL = 0;
        public static readonly int CLEAR_FLUX_KERNEL = 0;
        public static readonly int MARGOLUS_KERNEL = 2;
        public static readonly int INJECT_WATER_KERNEL = 3;
        public static readonly int CALC_FLUX_KERNEL = 4;
        public static readonly int RSLV_FLUX_KERNEL = 5;
        public static readonly int ERODE_KERNEL = 6;
        public static int THREADGROUP_SIZE_S = 8;
        public static int THREADGROUP_SIZE_L = 32;
        
        [field: Header("Simulation Settings"), Space]
        [field: SerializeField] public Vector3 SimulationCenter { get; private set; }
        [field: SerializeField] public float ParticleSize { get; private set; } = 1;
        [field: SerializeField, Range(1, 100)] public int TicksPerSecond { get; private set; } = 60;
        
        [field: Header("References"), Space]
        [field: SerializeField] public GameObject UserIntPrefab { get; private set; }
        [field: SerializeField] public ComputeShader KarstSimCompute { get; private set; }
        [field: SerializeField] public ComputeShader KarstExtractCompute { get; private set; }
        [field: SerializeField] public ComputeShader FluxClearCompute { get; private set; }
        [field: SerializeField] public Material ParticleMaterial { get; private set; }
        [field: SerializeField] public Mesh ParticleMesh { get; private set; }
        
        public Vector3Int SimulationResolution { get; set; }
        public KarstViewMode ViewMode { get; set; } = KarstViewMode.Particles;
        public float FloorAmount { get; set; }
        public float StoneAmount { get; set; }
        public float ClayAmount { get; set; }
        public float SandAmount { get; set; }
        public float LayerNoiseScale { get; set; }
        public int LayerNoiseSeed { get; set; }
        public int LayerNoiseOctaves { get; set; }
        public float FractureZoom { get; set; }
        public float FractureAngle { get; set; }
        public float FractureNoiseScale { get; set; }
        public int FractureNoiseSeed { get; set; }
        public float WaterInjectRate { get; set; }
        public float WaterColumnCellDensity { get; set; }
        public float PermeableThreshold { get; set; }
        public float ErosionRate { get; set; }

        public int GetVoxelCount()
        {
            return SimulationResolution.x * SimulationResolution.y * SimulationResolution.z;
        }

        public float GetDeltaTime()
        {
            return 1.0f / (float)TicksPerSecond;
        }
    }

    public enum KarstViewMode
    {
        Particles,
        Hologram
    }
}