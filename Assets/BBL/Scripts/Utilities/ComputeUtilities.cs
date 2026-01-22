using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Experimental.Rendering;
using UnityEngine.LowLevel;
using UnityEngine.Rendering;

public class ComputeUtilities
{
    private const int MAX_THREADS = 8;
#if UNITY_EDITOR
    private static ComputeShader copySliceCompute => (ComputeShader)AssetDatabase.LoadAssetAtPath("Assets/Midas/Shaders/Compute/General/Compute_TextureUtilities.compute", typeof(ComputeShader));
#endif  
    
    public static void SaveTextureAsAsset(Texture texture, string name, string folder)
    {
#if UNITY_EDITOR
        string path = folder + name + ".asset";
        AssetDatabase.CreateAsset(texture, path);
        AssetDatabase.SaveAssets();
#endif
    }

    public static RenderTexture InitializeTex(Vector2Int resolution, GraphicsFormat format, FilterMode filterMode, int depth = 0)
    {
        RenderTexture renderTexture = new RenderTexture(resolution.x, resolution.y, 0, format);
        renderTexture.enableRandomWrite = true;
        renderTexture.filterMode = filterMode;
        renderTexture.wrapMode = TextureWrapMode.Repeat;
        renderTexture.dimension = depth == 0 ? TextureDimension.Tex2D : TextureDimension.Tex3D;
        renderTexture.volumeDepth = depth;
        renderTexture.Create();

        return renderTexture;
    }

    public static Texture2D StoreTex2D(RenderTexture tex, 
        FilterMode filterMode = FilterMode.Point,
        TextureWrapMode wrapMode = TextureWrapMode.Repeat)
    {
        Texture2D tempTex = new Texture2D(tex.width, tex.height, TextureFormat.RGBAHalf, false);
        tempTex.filterMode = filterMode;
        tempTex.wrapMode = wrapMode;

        RenderTexture.active = tex;
        Rect region = new Rect(0, 0, tex.width, tex.height);
        tempTex.ReadPixels(region, 0, 0);
        tempTex.Apply();

        return tempTex;
    }

    public static Texture3D StoreTex3D(RenderTexture tex,
        FilterMode filterMode = FilterMode.Point,
        TextureWrapMode wrapMode = TextureWrapMode.Repeat)
    {
        int w = tex.width;
        int h = tex.height;
        int d = tex.volumeDepth;

        Texture3D tempTex = new Texture3D(w, h, d, TextureFormat.RGBAHalf, false);
        tempTex.filterMode = filterMode;
        tempTex.wrapMode = wrapMode;

        int sliceSize = w * h;
        Color[] pixels = new Color[sliceSize * d];

        RenderTexture sliceRT = new RenderTexture(w, h, 0, RenderTextureFormat.ARGBHalf);
        sliceRT.enableRandomWrite = true;
        sliceRT.Create();
        
#if UNITY_EDITOR

        for (int z = 0; z < d; z++)
        {
            int kernel = copySliceCompute.FindKernel("Copy3DSlice");
            copySliceCompute.SetTexture(kernel, "_Base", tex);
            copySliceCompute.SetTexture(kernel, "_Copy", sliceRT);
            copySliceCompute.SetInt("_Slice", z);

            Vector2Int threads = GetDispatchResolution(new Vector2Int(w, h), MAX_THREADS);
            copySliceCompute.Dispatch(kernel, threads.x, threads.y, 1);

            // Read slice back
            RenderTexture.active = sliceRT;
            Texture2D sliceTex = new Texture2D(w, h, TextureFormat.RGBAHalf, false);
            sliceTex.ReadPixels(new Rect(0, 0, w, h), 0, 0);
            sliceTex.Apply();

            Color[] slicePixels = sliceTex.GetPixels();
            Array.Copy(slicePixels, 0, pixels, z * sliceSize, sliceSize);
        }
        
#endif

        tempTex.SetPixels(pixels);
        tempTex.Apply();

        return tempTex;
    }

    public static Vector2Int GetDispatchResolution(Vector2Int resolution, int threadGroupSize)
    {
        int dispatchX = Mathf.CeilToInt((float)resolution.x / (float)threadGroupSize);
        int dispatchY = Mathf.CeilToInt((float)resolution.y / (float)threadGroupSize);

        return new Vector2Int(dispatchX, dispatchY);
    }
    
    public static Vector3Int GetDispatchResolution(Vector3Int resolution, int threadGroupSize)
    {
        int dispatchX = Mathf.CeilToInt((float)resolution.x / (float)threadGroupSize);
        int dispatchY = Mathf.CeilToInt((float)resolution.y / (float)threadGroupSize);
        int dispatchZ = Mathf.CeilToInt((float)resolution.z / (float)threadGroupSize);

        return new Vector3Int(dispatchX, dispatchY, dispatchZ);
    }
}