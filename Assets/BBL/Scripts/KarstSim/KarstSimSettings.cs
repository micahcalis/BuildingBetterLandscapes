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
    }
}