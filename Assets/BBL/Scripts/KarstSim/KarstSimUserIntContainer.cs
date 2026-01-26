using UnityEngine;
using UnityEngine.UI;

namespace BBL
{
    public class KarstSimUserIntContainer : MonoBehaviour
    {
        [field: Header("References"), Space]
        [field: SerializeField] public Button StartSimulationButton { get; private set; }
        [field: SerializeField] public Button ApplySettingsButton { get; private set; }
    }
}