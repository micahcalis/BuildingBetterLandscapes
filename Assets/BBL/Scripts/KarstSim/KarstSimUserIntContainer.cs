using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.PlayerLoop;
using UnityEngine.UI;

namespace BBL
{
    public class KarstSimUserIntContainer : MonoBehaviour
    {
        public static readonly string VIEW_PARTICLE_TEXT = "Voxel View";
        public static readonly string VIEW_HOLOGRAM_TEXT = "Holo View";
        public static readonly string PAUSE_TEXT = "Pause Simulation";
        public static readonly string RESUME_TEXT = "Resume Simulation";
        
        [field: Header("References"), Space]
        [field: SerializeField] public Button StartSimulationButton { get; private set; }
        [field: SerializeField] public Button EndSimulationButton { get; private set; }
        [field: SerializeField] public Button PauseSimulationButton { get; private set; }
        [field: SerializeField] public TextMeshProUGUI PauseSimulationText { get; private set; }
        [field: SerializeField] public Button ViewModeButton { get; private set; }
        [field: SerializeField] public TextMeshProUGUI ViewModeText { get; private set; }
        [field: SerializeField] public SliderDisplay ResolutionX { get; private set; }
        [field: SerializeField] public SliderDisplay ResolutionY { get; private set; }
        [field: SerializeField] public SliderDisplay ResolutionZ { get; private set; }
        [field: SerializeField] public SliderDisplay FloorPercentage { get; private set; }
        [field: SerializeField] public SliderDisplay StonePercentage { get; private set; }
        [field: SerializeField] public SliderDisplay ClayPercentage { get; private set; }
        [field: SerializeField] public SliderDisplay SandPercentage { get; private set; }
        [field: SerializeField] public SliderDisplay LayerNoiseScale { get; private set; }
        [field: SerializeField] public SliderDisplay LayerNoiseSeed { get; private set; }
        [field: SerializeField] public SliderDisplay LayerNoiseOctaves { get; private set; }
        [field: SerializeField] public SliderDisplay FractureZoom { get; private set; }
        [field: SerializeField] public SliderDisplay FractureAngle { get; private set; }
        [field: SerializeField] public SliderDisplay FractureNoiseScale { get; private set; }
        [field: SerializeField] public SliderDisplay FractureNoiseSeed { get; private set; }
        [field: SerializeField] public SliderDisplay WaterInjectRate { get; private set; }
        [field: SerializeField] public SliderDisplay WaterColumnCellDensity { get; private set; }
        [field: SerializeField] public SliderDisplay ErosionRate { get; private set; }
        
        public List<SliderDisplay> GetSliders()
        {
            return new List<SliderDisplay>()
            {
                ResolutionX,
                ResolutionY,
                ResolutionZ,
                FloorPercentage,
                StonePercentage,
                ClayPercentage,
                SandPercentage,
                LayerNoiseScale,
                LayerNoiseSeed,
                LayerNoiseOctaves,
                FractureZoom,
                FractureAngle,
                FractureNoiseScale,
                FractureNoiseSeed,
                WaterInjectRate,
                ErosionRate,
                WaterColumnCellDensity
            };
        }
    }
}
