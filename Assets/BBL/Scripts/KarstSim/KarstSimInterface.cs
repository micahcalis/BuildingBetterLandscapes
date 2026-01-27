using System;
using UnityEngine;
using UnityEngine.Events;
using Object = UnityEngine.Object;

namespace BBL
{
    public class KarstSimInterface
    {
        private KarstSimUserIntContainer container;
        private KarstSimSettings settings;
            
        public KarstSimInterface(KarstSimSettings settings, 
            Action onSimStart,
            Action onSimEnd)
        {
            GameObject instance = Object.Instantiate(settings.UserIntPrefab);
            container = instance.GetComponent<KarstSimUserIntContainer>();
            this.settings = settings;
            ConnectInterfaceInteractions(onSimStart, onSimEnd);
            OnSimEnd(null);
            ForceApplySettings();
        }

        private void ConnectInterfaceInteractions(Action onSimStart, Action onSimEnd)
        {
            container.StartSimulationButton.onClick.AddListener(() => OnSimStart(onSimStart));
            container.EndSimulationButton.onClick.AddListener(() => OnSimEnd(onSimEnd));
            container.ResolutionX.OnSliderChanged += SetResolutionX;
            container.ResolutionY.OnSliderChanged += SetResolutionY;
            container.ResolutionZ.OnSliderChanged += SetResolutionZ;
        }

        private void OnSimStart(Action onSimStart)
        {
            container.StartSimulationButton.gameObject.SetActive(false);
            container.ResolutionX.gameObject.SetActive(false);
            container.ResolutionY.gameObject.SetActive(false);
            container.ResolutionZ.gameObject.SetActive(false);
            container.EndSimulationButton.gameObject.SetActive(true);
            onSimStart?.Invoke();
        }

        private void OnSimEnd(Action onSimEnd)
        {
            container.StartSimulationButton.gameObject.SetActive(true);
            container.ResolutionX.gameObject.SetActive(true);
            container.ResolutionY.gameObject.SetActive(true);
            container.ResolutionZ.gameObject.SetActive(true);
            container.EndSimulationButton.gameObject.SetActive(false);
            onSimEnd?.Invoke();
        }
        
        private void SetResolutionX(float value)
        {
            settings.SimulationResolution = new Vector3Int((int)value,
                settings.SimulationResolution.y,
                settings.SimulationResolution.z);
        }
        private void SetResolutionY(float value)
        {
            settings.SimulationResolution = new Vector3Int(settings.SimulationResolution.x,
                (int)value,
                settings.SimulationResolution.z);
        }
        
        private void SetResolutionZ(float value)
        {
            settings.SimulationResolution = new Vector3Int(settings.SimulationResolution.x,
                settings.SimulationResolution.y,
                (int)value);
        }

        private void ForceApplySettings()
        {
            container.ResolutionX.Invoke();
            container.ResolutionY.Invoke();
            container.ResolutionZ.Invoke();
        }
    }
}