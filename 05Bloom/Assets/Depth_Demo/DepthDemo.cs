using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DepthDemo : MonoBehaviour
{
    public Material m_material;
[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!m_material)
        {
            Debug.LogError("no material");
        }
        
        Graphics.Blit(src,dest,m_material);
    }
}
