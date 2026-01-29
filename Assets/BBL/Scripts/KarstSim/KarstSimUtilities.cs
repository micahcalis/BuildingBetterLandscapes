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
        
        public static Vector3Int GetThreadGroupsHalf(RenderTexture renderTexture, float groupSize)
        {
            return new Vector3Int(Mathf.CeilToInt((float)renderTexture.width / (groupSize * 2.0f)), 
                Mathf.CeilToInt((float)renderTexture.height / (groupSize * 2.0f)), 
                Mathf.CeilToInt((float)renderTexture.volumeDepth / (groupSize * 2.0f)));
        }

        public static Vector2Int GetThreadGroups2D(int width, int height, float groupSize)
        {
            return new Vector2Int(Mathf.CeilToInt((float)width / groupSize),
                Mathf.CeilToInt((float)height / groupSize));
        }

        public static int GetThreadGroups1D(int depth, float groupSize)
        {
            return Mathf.CeilToInt((float)depth / groupSize);
        }
    }
}