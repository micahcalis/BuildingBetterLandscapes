using System.Collections.Generic;
using UnityEngine;

public class MaterialPropertyCache
{
    private readonly Dictionary<string, int> propertyIDs = new();

    public MaterialPropertyCache()
    {
        propertyIDs.Clear();
    }
    
    public int Get(string propertyName)
    {
        if (propertyIDs.TryGetValue(propertyName, out int id)) return id;
        
        id = Shader.PropertyToID(propertyName);
        propertyIDs[propertyName] = id;
        return id;
    }
}