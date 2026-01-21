using System;
using UnityEngine;

namespace BBL
{
    [Serializable]
    public class SphereTracingParams
    {
        [SerializeField, Range(0, 200)] private int maxSteps;
        [SerializeField] private float maxDistance;

        private MaterialPropertyCache cache = new();

        public void SetSphereTracingBlock(MaterialPropertyBlock block, Camera camera)
        {
            block.SetInt(cache.Get("_RayMaxSteps"), maxSteps);
            block.SetFloat(cache.Get("_RayMaxDistance"), maxDistance);
        }
    }
}