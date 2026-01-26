using System;
using UnityEngine;

namespace BBL
{
    public class KarstEventHandler : MonoBehaviour
    {
        public event Action OnSimStart;
        
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
            
            karstSimInterface = new KarstSimInterface(settings, StartSim);
        }
    }
}