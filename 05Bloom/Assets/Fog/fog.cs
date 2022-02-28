using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class fog : MonoBehaviour
{
    #region const data
    private const string m_FrustumCornersRay = "_FrustumCornersRay";
    private const string fogCol = "_FogColor";
    private const string fogDen = "_FogDensity";
    private const string fogSt = "_FogStart";
    private const string fogEn = "_FogEnd";
    
    #endregion

    private Material m_Material;

    public Camera camera;
    public Shader FogShader;
    [Range(0,3)]
    public float fogDensity;
    public Color fogColor;
    public float fogStart = 0;
    public float fogEnd = 2.0f;

    [Range(0,0.3f)]
    public float _FogXSpeed;
    [Range(0,0.3f)]
    public float _FogYSpeed;
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!m_Material)
        {
            m_Material= new Material(FogShader);
        }

        Matrix4x4 frustumCorners = Matrix4x4.identity;
        float fov = camera.fieldOfView;
        float near = camera.nearClipPlane;
        float aspect = camera.aspect;

        float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
        var cameraTransform = camera.transform;
        Vector3 toRight = cameraTransform.right  * halfHeight * aspect;
        Vector3 toTop = cameraTransform.up * halfHeight;
        
        // representing the blue axis of the transform in world space
        Vector3 topLeft = cameraTransform.forward * near +   toTop-toRight;
        // magnitude ,返回向量的长度
        float scale = topLeft.magnitude / near;
        topLeft.Normalize();
        topLeft *= scale;
        
        //
        Vector3 topRight = cameraTransform.forward * near + toRight + toTop;
        topRight.Normalize();
        topRight *= scale;
        

        //
        Vector3 bottmLeft = cameraTransform.forward * near - toTop - toRight;
        bottmLeft.Normalize();
        bottmLeft *= scale;
        //
        Vector3 bottmRigh = cameraTransform.forward * near - toTop + toRight;
        bottmRigh.Normalize();
        bottmRigh *= scale;
        
        
        frustumCorners.SetRow(0,bottmLeft);
        frustumCorners.SetRow(1,bottmRigh);
        frustumCorners.SetRow(2,topRight);
        frustumCorners.SetRow(3,topLeft);
        
        m_Material.SetMatrix(m_FrustumCornersRay,frustumCorners);
        
        m_Material.SetColor(fogCol,fogColor);
        m_Material.SetFloat(fogDen,fogDensity);
        m_Material.SetFloat(fogSt,fogStart);
        m_Material.SetFloat(fogEn,fogEnd);
        m_Material.SetFloat("_FogXSpeed",_FogXSpeed);
        m_Material.SetFloat("_FogYSpeed",_FogYSpeed);
        Graphics.Blit(src,dest,m_Material);
    }
}
