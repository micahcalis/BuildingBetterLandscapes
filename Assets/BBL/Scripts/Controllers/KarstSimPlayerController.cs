using UnityEngine;

namespace BBL
{
    // This is largely AI generated
    public class KarstSimPlayerController : MonoBehaviour
    {
        [Header("Target")] [SerializeField] private KarstSimRenderFeature feature;

        [Header("Settings")] [SerializeField] private float distance = 15.0f;
        [SerializeField] private float sensitivity = 100.0f;
        [SerializeField] private float zoomSpeed = 2.0f;

        [Header("Limits")] [SerializeField] private float minDistance = 2.0f;
        [SerializeField] private float maxDistance = 50.0f;

        private Vector2 currentAngles;
        private Vector3 target => feature.KarstSimSettings.SimulationCenter;

        void Start()
        {
            Vector3 angles = transform.eulerAngles;
            currentAngles.x = angles.x;
            currentAngles.y = angles.y;
        }

        void LateUpdate()
        {
            if (feature == null)
                return;

            Vector2 input = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));

            float scroll = Input.GetAxis("Mouse ScrollWheel");
            distance -= scroll * zoomSpeed * 10.0f;
            distance = Mathf.Clamp(distance, minDistance, maxDistance);

            Orbit(target, input, ref currentAngles, distance, sensitivity);
        }

        private void Orbit(Vector3 targetPos, Vector2 input, ref Vector2 orbitAngles, float dist, float sens)
        {
            orbitAngles.y -= input.x * sens * Time.deltaTime;
            orbitAngles.x += input.y * sens * Time.deltaTime;
            orbitAngles.x = Mathf.Clamp(orbitAngles.x, -89f, 89f);

            Quaternion rotation = Quaternion.Euler(orbitAngles.x, orbitAngles.y, 0);
            Vector3 negDistance = new Vector3(0.0f, 0.0f, -dist);
            Vector3 position = rotation * negDistance + targetPos;

            transform.rotation = rotation;
            transform.position = position;
        }
    }
}
