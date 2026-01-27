using System;
using UnityEngine;

namespace BBL
{
    public class KarstEventHandler : MonoBehaviour
    {
        public event Action OnSimStart;
        public event Action OnSimEnd;
        
        private KarstSimSettings settings;
        private KarstSimInterface karstSimInterface;
        
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
            }

            void EndSim()
            {
                OnSimEnd?.Invoke();
            }
            
            karstSimInterface = new KarstSimInterface(settings, StartSim, EndSim);
        }
    }
}