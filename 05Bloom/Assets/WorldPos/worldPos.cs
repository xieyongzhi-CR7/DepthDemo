using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class worldPos : MonoBehaviour
{

    #region constData

    private string Matri = "_InterpolateRay";
    

    #endregion
    public Camera m_Camera;

    private Material m_material;
    // Start is called before the first frame update
    void Start()
    {
        m_material = new Material(Shader.Find("custom/worldPos"));
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        float far = m_Camera.farClipPlane;
        float near = m_Camera.nearClipPlane;
        float aspect = m_Camera.aspect;
        var cameraTrans = m_Camera.transform;
        float tanFOV = Mathf.Tan(m_Camera.fieldOfView * 0.5f * Mathf.Rad2Deg);
        
        Vector3 right = far * tanFOV * aspect *cameraTrans .right;
        Vector3 up = far * tanFOV * cameraTrans.up;
        Vector3 forward = far * cameraTrans.forward;

        Vector3 topR = forward + right + up;
        Vector3 topL = forward - right + up;
        Vector3 bomR = forward + right - up;
        Vector3 bomL = forward - right - up;
        
        Matrix4x4 interpolateRay  = Matrix4x4.identity;
        interpolateRay.SetRow(0,bomL);
        interpolateRay.SetRow(1,bomR);
        interpolateRay.SetRow(2,topR);
        interpolateRay.SetRow(3,topL);
        
        m_material.SetMatrix(Matri,interpolateRay);
        
        
        
    }
}
