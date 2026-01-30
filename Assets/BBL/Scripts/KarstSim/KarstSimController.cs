using UnityEngine;

namespace BBL
{
    public class KarstSimController
    {
        private static int SMALL_STEPS = 1;
        
        public static KarstSimulation Simulation { get; private set; }
        
        private KarstSimSettings settings;
        private int fluidTimer;

        public KarstSimController(KarstSimSettings settings)
        {
            this.settings = settings;
        }

        public void StartSimulation()
        {
            Debug.Log("Start Simulation");
            Simulation = new KarstSimulation();
            CreateSimulationVolume();
            Simulation.ClearFlux(settings);
            Simulation.SetActive(true);
        }

        public void EndSimulation()
        {
            Debug.Log("End Simulation");
            Dispose();
            Simulation.SetActive(false);
        }

        public void SimulationUpdate(float bigDeltaTime)
        {
            BigUpdate(bigDeltaTime);

            float smallDeltaTime = bigDeltaTime / SMALL_STEPS;

            for (int i = 0; i < SMALL_STEPS; i++)
            {
                SmallUpdate(smallDeltaTime);
            }
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

        private void SmallUpdate(float deltaTime)
        {
            Simulation.MargolusSwap(settings, true);
            Simulation.MargolusSwap(settings, false);
        }

        private void BigUpdate(float deltaTime)
        {
            Simulation.InjectWater(settings, deltaTime);
            Simulation.CalculateFlux(settings, deltaTime);
            Simulation.ErodeVolume(settings, deltaTime);
            Simulation.ResolveFlux(settings);
        }
    }   
}