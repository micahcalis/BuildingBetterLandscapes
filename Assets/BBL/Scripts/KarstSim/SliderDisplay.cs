using System;
using UnityEngine;
using UnityEngine.UI;

namespace BBL
{
    public class SliderDisplay : MonoBehaviour
    {
        public event Action<float> OnSliderChanged;
        
        [field: SerializeField] public Slider Slider { get; private set; }
        [field: SerializeField] public Text Text { get; private set; }

        public void Awake()
        {
            Slider.onValueChanged.AddListener(CallOnSliderChanged);
            CallOnSliderChanged(Slider.value);
        }

        private void CallOnSliderChanged(float val)
        {
            Text.text = val.ToString();
            OnSliderChanged?.Invoke(val);
        }
    }
}