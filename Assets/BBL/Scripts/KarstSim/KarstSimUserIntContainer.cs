using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace BBL
{
    public class KarstSimUserIntContainer : MonoBehaviour
    {
        [field: Header("References"), Space]
        [field: SerializeField] public Button StartSimulationButton { get; private set; }
        [field: SerializeField] public Button EndSimulationButton { get; private set; }
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
                FractureNoiseSeed
            };
        }
    }
}
