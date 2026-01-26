using System;
using UnityEngine;
using Object = UnityEngine.Object;

namespace BBL
{
    public class KarstSimInterface
    {
        private KarstSimUserIntContainer container;
            
        public KarstSimInterface(KarstSimSettings settings, 
            Action onSimStart)
        {
            GameObject instance = Object.Instantiate(settings.UserIntPrefab);
            container = instance.GetComponent<KarstSimUserIntContainer>();
            ConnectInterfaceInteractions(onSimStart);
        }

        private void ConnectInterfaceInteractions(Action onSimStart)
        {
            container.StartSimulationButton.onClick.AddListener(() => onSimStart?.Invoke());
        }
    }
}