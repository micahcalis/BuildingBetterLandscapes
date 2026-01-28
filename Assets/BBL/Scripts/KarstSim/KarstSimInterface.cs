using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UIElements;
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
            container.FloorPercentage.OnSliderChanged += SetFloorAmount;
            container.StonePercentage.OnSliderChanged += SetStoneAmount;
            container.ClayPercentage.OnSliderChanged += SetClayAmount;
            container.SandPercentage.OnSliderChanged += SetSandAmount;
            container.LayerNoiseScale.OnSliderChanged += SetLayerNoiseScale;
            container.LayerNoiseSeed.OnSliderChanged += SetLayerNoiseSeed;
            container.LayerNoiseOctaves.OnSliderChanged += SetLayerNoiseOctaves;
            container.FractureZoom.OnSliderChanged += SetFractureZoom;
            container.FractureNoiseScale.OnSliderChanged += SetFractureNoiseScale;
            container.FractureNoiseSeed.OnSliderChanged += SetFractureNoiseSeed;
            container.FractureAngle.OnSliderChanged += SetFractureAngle;
        }

        private void OnSimStart(Action onSimStart)
        {
            container.StartSimulationButton.gameObject.SetActive(false);
            container.EndSimulationButton.gameObject.SetActive(true);
            SetSlidersActive(false);
            onSimStart?.Invoke();
        }

        private void OnSimEnd(Action onSimEnd)
        {
            container.StartSimulationButton.gameObject.SetActive(true);
            container.EndSimulationButton.gameObject.SetActive(false);
            SetSlidersActive(true);
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

        private void SetFloorAmount(float value)
        {
            settings.FloorAmount = value / 100f;
        }

        private void SetStoneAmount(float value)
        {
            settings.StoneAmount = value / 100f;
        }
        private void SetClayAmount(float value)
        {
            settings.ClayAmount = value / 100f;
        }
        
        private void SetSandAmount(float value)
        {
            settings.SandAmount = value / 100f;
        }

        private void SetLayerNoiseScale(float value)
        {
            settings.LayerNoiseScale = 1.0f / value;
        }

        private void SetLayerNoiseSeed(float value)
        {
            settings.LayerNoiseSeed = (int)value;
        }

        private void SetLayerNoiseOctaves(float value)
        {
            settings.LayerNoiseOctaves = (int)value;
        }

        private void SetFractureZoom(float value)
        {
            settings.FractureZoom = 1.0f / value;
        }

        private void SetFractureAngle(float value)
        {
            settings.FractureAngle = Mathf.Deg2Rad * value;
        }

        private void SetFractureNoiseScale(float value)
        {
            settings.FractureNoiseScale = 1.0f / value;
        }

        private void SetFractureNoiseSeed(float value)
        {
            settings.FractureNoiseSeed = (int)value;
        }

        private void ForceApplySettings()
        {
            List<SliderDisplay> sliders = container.GetSliders();
            foreach (SliderDisplay slider in sliders)
            {
                slider.Invoke();
            }
        }

        private void SetSlidersActive(bool active)
        {
            List<SliderDisplay> sliders = container.GetSliders();
            foreach (SliderDisplay slider in sliders)
            {
                slider.gameObject.SetActive(active);
            }
        }
    }
}