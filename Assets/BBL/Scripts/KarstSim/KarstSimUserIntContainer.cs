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
    }
}