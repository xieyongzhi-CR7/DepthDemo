using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class DrawLine1 : MonoBehaviour
{
    [SerializeField]
    public RenderTexture rt;
    private Camera mainCam;
    private Material drawMat;
    [Range(0,100)]
    public float _BrushStrength;
    [Range(0,1000)]
    public float _BrushSize;
    void Start()
    {
        mainCam = Camera.main.GetComponent<Camera>();
        drawMat = GetComponent<MeshRenderer>().material;
        rt = new RenderTexture(1024,1024,0,GraphicsFormat.R32G32B32A32_SFloat);
        drawMat.SetTexture("_MaskTex", rt);
    }
    Vector4 vec = new Vector4();
    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Ray ray = mainCam.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray,out var hit))
            {
                vec.x =  hit.textureCoord.x;
                vec.y = hit.textureCoord.y;
                Debug.LogError("hit name ="+hit.transform.name+" pos = "+hit.textureCoord.x+" , "+hit.textureCoord.y+" u="+vec.x+" v="+vec.y);
                drawMat.SetVector("_HitUV",vec);
                drawMat.SetFloat("_Strength", _BrushStrength);
                drawMat.SetFloat("_powSize", _BrushSize);
                RenderTexture temp = RenderTexture.GetTemporary(rt.width,rt.height,0,rt.format);
                Graphics.Blit(rt,temp);
                Graphics.Blit(temp,rt,drawMat);
                RenderTexture.ReleaseTemporary(temp);
            }
        }        
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0,0,256,256),rt,ScaleMode.ScaleToFit,false,1 );
    }
}
