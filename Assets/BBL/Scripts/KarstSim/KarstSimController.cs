using UnityEngine;

namespace BBL
{
    public class KarstSimController
    {
        public static KarstSimulation Simulation { get; private set; }
        
        private KarstSimSettings settings;
        private bool initialized = false;

        public KarstSimController(KarstSimSettings settings)
        {
            this.settings = settings;
        }

        public void StartSimulation()
        {
            Debug.Log("Start Simulation");
        }

        public void Dispose()
        {
            Simulation?.Dispose();
        }
    }
}