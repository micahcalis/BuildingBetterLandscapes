using System;
using System.Collections;
using UnityEngine;

namespace BBL
{
    public class KarstEventHandler : MonoBehaviour
    {
        public event Action OnSimStart;
        public event Action OnSimEnd;
        public event Action<bool> OnSetPause;
        public event Action<float> OnSimUpdate;
        
        private KarstSimSettings settings;
        private KarstSimInterface karstSimInterface;
        private KarstSimulation simulation => KarstSimController.Simulation;
        
        private void Start()
        {
            CreateUserInterface();
        }

        public void Initialize(KarstSimSettings settings)
        {
            this.settings = settings;
        }

        private void CreateUserInterface()
        {
            void StartSim()
            {
                OnSimStart?.Invoke();
                StartCoroutine(SimulationUpdate());
            }

            void EndSim()
            {
                OnSimEnd?.Invoke();
            }

            void SetPause(bool pause)
            {
                OnSetPause?.Invoke(pause);
            }
            
            karstSimInterface = new KarstSimInterface(settings, StartSim, EndSim, SetPause);
        }

        private IEnumerator SimulationUpdate()
        {
            float deltaTime = settings.GetDeltaTime();
            
            while (true)
            {
                if (simulation != null && simulation.Active)
                {
                    OnSimUpdate?.Invoke(deltaTime);
                }
                
                yield return new WaitForSeconds(deltaTime);
            }
        }
    }
}