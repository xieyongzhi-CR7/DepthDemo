using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class DrawMayFoot : MonoBehaviour
{
    private RenderTexture rt;
    // Start is called before the first frame update
    public Material drawMat;
    private Camera mainCam;
    private Material snowMat; 
    void Start()
    {
        rt = new RenderTexture(1024,1024,0,GraphicsFormat.R16G16B16A16_SFloat);
        drawMat.SetTexture("_MainTex",rt);
        mainCam = Camera.main.GetComponent<Camera>();
    }

    Vector4 vec = new Vector4(0,0,0,0);
    // Update is called once per frame
    void Update()
    {
        
        if(Input.GetMouseButton(0))
        {
            Ray ray =  mainCam.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray,out var hit))
            {
                Debug.LogError("hitName ="+hit.transform.name);
                vec.x = hit.textureCoord.x;
                vec.y = hit.textureCoord.y;
                drawMat.SetVector("_HitUV",vec);
                var temp = RenderTexture.GetTemporary(rt.width, rt.height);
                Graphics.Blit(rt,temp);
                Graphics.Blit(temp,rt,drawMat);
                //snowMat.SetTexture("_MaskTex",rt);
            }
        }
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0,0,256,256), rt,ScaleMode.ScaleToFit,false);
    }
}
