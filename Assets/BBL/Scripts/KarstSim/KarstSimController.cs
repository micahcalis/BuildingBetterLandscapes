using System.Net.Sockets;
using UnityEngine;

namespace BBL
{
    public class KarstSimController
    {
        public static KarstSimulation Simulation { get; private set; }
        
        private KarstSimSettings settings;

        public KarstSimController(KarstSimSettings settings)
        {
            this.settings = settings;
        }

        public void StartSimulation()
        {
            Debug.Log("Start Simulation");
            Simulation = new KarstSimulation();
            CreateSimulationVolume();
            Simulation.SetActive(true);
        }

        public void EndSimulation()
        {
            Debug.Log("End Simulation");
            Dispose();
            Simulation.SetActive(false);
        }

        public void Dispose()
        {
            Simulation?.Dispose();
        }

        private void CreateSimulationVolume()
        {
            Simulation.Initialize(settings);
            Simulation.Fill(settings);
            Simulation.Fracture(settings);
        }
    }
}