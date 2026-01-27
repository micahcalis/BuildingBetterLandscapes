using UnityEngine;

namespace BBL
{
    public static class KarstSimUtilities
    {
        public static Vector3Int GetThreadGroupsFull(RenderTexture renderTexture, float groupSize)
        {
            return new Vector3Int(Mathf.CeilToInt((float)renderTexture.width / groupSize), 
                Mathf.CeilToInt((float)renderTexture.height / groupSize), 
                Mathf.CeilToInt((float)renderTexture.volumeDepth / groupSize));
        }
    }
}