using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.PackageManager;
using UnityEngine;
using UnityEngine.UI;
[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class Edage : MonoBehaviour
{
    public Shader EdgeShader;
    Material edge;

    public Color _EdgeColor;
    public Color _BackgroundColor;
    public int _EdgeOnly;
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!edge)
        {
            edge = new Material(EdgeShader);
        }
        edge.SetColor("_EdgeColor",_EdgeColor);
        edge.SetColor("_BackgroundColor",_BackgroundColor);
        edge.SetFloat("_EdgeOnly",_EdgeOnly);
        Graphics.Blit(src,dest,edge);
    }
}
