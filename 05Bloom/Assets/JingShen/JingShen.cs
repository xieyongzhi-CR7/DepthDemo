using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class JingShen : MonoBehaviour
{
    #region passID
    private const int ProfileId = 0;
    private const int DownSampleId = 1;
    private const int UpSampleId = 2;
    private const int BlendId = 3;
    private const int JingShenId = 4;
    #endregion
    
    private Material m_material;
    public Shader JingShenShader;
[Range(0,8)]
    public int Interations = 4;

    private RenderTexture[] m_RenderTextures;
    public float Threshold =1;
    [Range(0,1)]
    public float SoftThreshold = 0.5f;
    [Range(0,10)]
    public float Intensity = 1;

    #region 景深
[Range(0,1)]
    public float _FocalDistance;
[Range(0,20)]
    public float _farBlurScale;
[Range(0,200)]
    public float _nearBlurScale;
    #endregion
    private void Start()
    {
        m_RenderTextures = new RenderTexture[4];
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!m_material)
        {
            m_material = new Material(JingShenShader);
            m_material.hideFlags = HideFlags.HideAndDontSave;
        }

        #region 景深
        m_material.SetFloat("_farBlurScale",_farBlurScale);
        m_material.SetFloat("_FocalDistance",_FocalDistance);
        m_material.SetFloat("_nearBlurScale",_nearBlurScale);
        

        #endregion
        m_material.SetFloat("_Threshold", Threshold);
        m_material.SetFloat("_Intensity", Intensity);
        float knee = Threshold - SoftThreshold;
        Vector4 filter;
        filter.x = Threshold;
        filter.y = Threshold - knee;
        filter.z = 2 * knee;
        filter.w = 4 * knee + 0.00001f;
        m_material.SetVector("_Filter", filter);
        
        int width = src.width;
        int height = src.height;
        RenderTextureFormat format = src.format;
        width /= 2;
        height /= 2;
        RenderTexture currentDesternation = m_RenderTextures[0] = RenderTexture.GetTemporary(width,height,0,format);
        
        Graphics.Blit(src,currentDesternation,m_material,ProfileId);
        RenderTexture currentSource = currentDesternation;
        int i = 0;
        for (; i < Interations; i++)
        {
            width /= 2;
            height /= 2;
            if (height <2)
            {
                break;
            }
            currentDesternation = m_RenderTextures[i] = RenderTexture.GetTemporary(width,height,0,format);
            Graphics.Blit(currentSource,currentDesternation,m_material,DownSampleId);
            currentSource = currentDesternation;
        }

        for ( i -= 2; i > 0; i--)
        {
            currentDesternation = m_RenderTextures[i];
            Graphics.Blit(currentSource,currentDesternation,m_material,UpSampleId);
            RenderTexture.ReleaseTemporary(currentSource);
            m_RenderTextures[i] = null;
            currentSource = currentDesternation;
        }
        m_material.SetTexture("_SourceTex",src);
        Graphics.Blit(currentSource,dest,m_material,BlendId);
        RenderTexture.ReleaseTemporary(currentDesternation);
    }
}
