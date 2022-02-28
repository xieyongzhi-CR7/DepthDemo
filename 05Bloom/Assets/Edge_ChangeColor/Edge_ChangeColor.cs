using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class Edge_ChangeColor : MonoBehaviour
{
    private Material m_material;
    public Shader ChangeColor;
    public Color _EdgeColor = new Color(1,0,0,1);
    public Color _NoEdgeColor = new Color(1,1,1,1);
    public Vector4 _Sensitivity = new Vector4(1,1,1,1);
    [Range(1,10)]
    public float _SampleDistance = 1;

    [Range(0,1)]
    public float _testChangeData;
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(!m_material)
        {
            m_material = new Material(ChangeColor);
        }

        m_material.SetFloat("_testChangeData",_testChangeData);
        m_material.SetColor("_EdgeColor",_EdgeColor);
        m_material.SetColor("_NoEdgeColor",_NoEdgeColor);
        m_material.SetFloat("_SampleDistance",_SampleDistance);
        m_material.SetVector("_Sensitivity",_Sensitivity);
        //RenderTexture curSource = RenderTexture.GetTemporary(width, height, 0, src.format);
        Graphics.Blit(src,dest,m_material);
    }
}
