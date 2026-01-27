using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace BBL
{
    public class SliderDisplay : MonoBehaviour
    {
        public event Action<float> OnSliderChanged;
        
        [field: SerializeField] public Slider Slider { get; private set; }
        [field: SerializeField] public TextMeshProUGUI Text { get; private set; }

        private void Awake()
        {
            Slider.onValueChanged.AddListener(CallOnSliderChanged);
            CallOnSliderChanged(Slider.value);
        }

        public void Invoke()
        {
            CallOnSliderChanged(Slider.value);
        }

        private void CallOnSliderChanged(float val)
        {
            Text.text = val.ToString();
            OnSliderChanged?.Invoke(val);
        }
    }
}