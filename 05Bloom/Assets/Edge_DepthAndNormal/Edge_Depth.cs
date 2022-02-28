using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
//[ImageEffectAllowedInSceneView]
public class Edge_Depth : MonoBehaviour
{
    private Material m_material;
    public Shader Edge_DepthShader;

    public Color _EdgeColor = new Color(1,0,0,1);
    public Color _NoEdgeColor = new Color(1,1,1,1);
    public Vector4 _Sensitivity = new Vector4(1,1,1,1);
    [Range(1,10)]
    public float _SampleDistance = 1;
    
    
    
    private Camera m_Camera;
    // Start is called before the first frame update
    private void OnEnable()
    {
        m_Camera = gameObject.GetComponent<Camera>();
        m_Camera.depthTextureMode = DepthTextureMode.DepthNormals;
    }

    void Start()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {

        if (!m_material)
        {
            m_material = new Material(Edge_DepthShader);
        }
        m_material.SetColor("_EdgeColor",_EdgeColor);
        m_material.SetColor("_NoEdgeColor",_NoEdgeColor);
        m_material.SetFloat("_SampleDistance",_SampleDistance);
        m_material.SetVector("_Sensitivity",_Sensitivity);
        Graphics.Blit(src,dest,m_material);
    }
}
