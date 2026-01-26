using UnityEngine.Rendering;

namespace BBL
{
    public class KarstSimulation
    {
        public RTHandle SimulationVolume;

        public void Update()
        {
            
        }

        public void Dispose()
        {
            SimulationVolume?.Release();
        }
    }
}