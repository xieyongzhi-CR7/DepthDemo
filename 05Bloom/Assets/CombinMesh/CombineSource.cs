// using System.Collections;
// using System.Collections.Generic;
// using UnityEngine;
//
// public class CombineSource : MonoBehaviour
// {
// //要合并的材质贴图
//     string[] CombineTextureNameList = new string[1] { "_BaseMap" };
// //合并后的贴图数组
//     RenderTexture[] combineTextures;
//
//     private int combineTextureHeight = 1024;
//     private int combineTextureWidth = 1024;
//     //合成创建新贴图
//     private void GenerateTextures(ref Material combineMaterial,Material[] combineMaterialList)
//     {
//         bool hasProcessTextureUV = false;
//         for (int i = 0; i < combineTextures.Length; i++)
//         {
//
//             RenderTexture rt = combineTextures[i];
//             if (rt == null)
//                 rt = RenderTexture.GetTemporary(combineTextureWidth, combineTextureHeight, 0);
//             rt.DiscardContents();
//             ...
//         }
//     }
//     
//     //合成创建新贴图
//     private void GenerateTextures(ref Material combineMaterial,Material[] combineMaterialList)
//     {
//         for (int i = 0; i < combineTextures.Length; i++){
//             ...
//             packingResult = new Rect[length];
//             for (int j = 0; j < length; j++)
//             {
//                 float gridXMin = (j % scale) / scale;
//                 float gridYMin = (j / (int)scale) / scale;
//                 float gridXMax = gridXMin + 1f / scale;
//                 float gridYMax = gridYMin + 1f / scale;
//                 packingResult[j] = new Rect(gridXMin, gridYMin, gridXMax, gridYMax);
//                 Debug.Log(packingResult[j].ToString());
//                 GPUPackTextureTile(ref rt, combineMaterialList[j], j);
//             }
//             if (!hasProcessTextureUV)
//             {
//                 ProcessTextureUV();
//                 hasProcessTextureUV = true;
//             }
//             combineMaterial.SetTexture(CombineTextureNameList[i], rt);
//             SetUVs(ref combineMesh);
//         }
//     }
//     
//     //创建级联贴图
//     void GPUPackTextureTile(ref RenderTexture dstTex,Material combineMaterial,int srcIdx)
//     {
//         Rect r = packingResult[srcIdx];
//         PackMaterial.CopyPropertiesFromMaterial(combineMaterial);
//         BlitEx(ref dstTex, packMaterial, r);
//     }
//
//     //将结果渲染到纹理
//     static void BlitEx(ref RenderTexture dst, Material mat, Rect rect)
//     {
//         Graphics.SetRenderTarget(dst);
//         mat.SetPass(0);
//
//         GL.PushMatrix();
//         GL.LoadOrtho();
//         GL.Begin(GL.QUADS);
//         GL.TexCoord2(rect.xMin, rect.yMax); GL.Vertex3(rect.xMin, rect.yMax, 0.1f);
//         GL.TexCoord2(rect.xMax, rect.yMax); GL.Vertex3(rect.xMax, rect.yMax, 0.1f);
//         GL.TexCoord2(rect.xMax, rect.yMin); GL.Vertex3(rect.xMax, rect.yMin, 0.1f);
//         GL.TexCoord2(rect.xMin, rect.yMin); GL.Vertex3(rect.xMin, rect.yMin, 0.1f);
//         GL.End();
//         GL.PopMatrix();
//     }
//     
//     
//     //给合并网格赋值新的uv坐标
//     public void SetUVs(ref Mesh combinedMesh)
//     {
//         //非优化需要每帧去赋值
//         if (modifiedCombinedUvs != null && modifiedCombinedUvs.Length > 0)
//         {
//             combinedMesh.uv = modifiedCombinedUvs;
//         }
//     }
//
//     //计算uv坐标
//     void ProcessTextureUV()
//     {
//         for (int rectIndex = 0; rectIndex < packingResult.Length; rectIndex++)
//         {
//             int uvIndex = 0;
//
//             for (int i = 0; i < rectIndex; i++)
//             {
//                 uvIndex += uvLengthArray[i];
//             }
//
//             for (int i = 0; i < uvLengthArray[rectIndex]; i++)
//             {
//                 modifiedCombinedUvs[uvIndex].x = UVLerp(packingResult[rectIndex].xMin,
//                     packingResult[rectIndex].xMax, originCombinedUvs[uvIndex].x);
//                 modifiedCombinedUvs[uvIndex].y = UVLerp(packingResult[rectIndex].yMin,
//                     packingResult[rectIndex].yMax, originCombinedUvs[uvIndex].y);
//                 uvIndex++;
//             }
//         }
//     }
//
//     //映射合并后的uv坐标
//     private float UVLerp(float newUvMin, float newUvMax, float oldUv)
//     {
//         if (oldUv < 0 || oldUv > 1)
//         {
//             oldUv = oldUv - Mathf.Floor(oldUv);
//         }
//
//         float ret = Mathf.Lerp(newUvMin, newUvMax, oldUv);
//         return ret;
//     }
//     
//     
//     
//     
//     
//     
//     
// }
