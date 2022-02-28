using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class CombineMesh_DiffMat
{
    
    [MenuItem("测试/combineMesh_DiffMat")]
    public static void CombineMeshDiffMat()
    {
        var selectObj = Selection.activeObject;
        if (!selectObj)
        {
            Debug.LogError("没有选中任何物体，请选择后再执行操作");
            return;
        }
        //Vector3 center;
        var meshFs = Selection.activeTransform.GetComponentsInChildren<MeshFilter>();
        var meshRenders = Selection.activeTransform.GetComponentsInChildren<MeshRenderer>();
        CombineInstance[] combine = new CombineInstance[meshFs.Length];
        var centerPos = GetCenter(meshFs);
        Material[] mats= new Material[meshFs.Length];
        for (int i = 0; i < meshFs.Length; i++)
        {
            combine[i].mesh = meshFs[i].sharedMesh;
            meshFs[i].transform.position = meshFs[i].transform.position - centerPos;
            combine[i].transform = meshFs[i].transform.localToWorldMatrix;
            mats[i] = meshRenders[i].sharedMaterial;
            meshRenders[i].enabled = false;
        }
        var thisMeshRender = Selection.activeTransform.GetComponent<MeshRenderer>();
        thisMeshRender.materials = mats;
        var newMesh = new Mesh();
        var thisMeshFilter = Selection.activeTransform.GetComponent<MeshFilter>();
        // combineMesh 第二个参数 true:合并生成一个大网格;  第二个参数是false：合并生成子网格；
        newMesh.CombineMeshes(combine,false);
        thisMeshFilter.mesh = newMesh;
    }

    static Vector3 GetCenter(Component[] components)
    {
        if (components== null || components.Length<=0)
        {
            Debug.LogError("传入的参数有误");
            return Vector3.zero;
        }
        Vector3 min = Vector3.zero;
        Vector3 max = Vector3.zero;
        for (int i = 0; i < components.Length; i++)
        {
            min = Vector3.Min(min, components[i].transform.position);
            max = Vector3.Max(max, components[i].transform.position);
        }
        return min + (max-min)/2;
    }

    [MenuItem("测试/comebineMesh_DiffMat_CombineTexUv")]
    static void CombineMesh_DiffMat_ComTexUV()
    {
        var selectObj = Selection.activeObject;
        if (!selectObj)
        {
            Debug.LogError("没有选中任何物体，请选择后再执行操作");
            return;
        }
        //Vector3 center;
        var meshFs = Selection.activeTransform.GetComponentsInChildren<MeshFilter>();
        var meshRenders = Selection.activeTransform.GetComponentsInChildren<MeshRenderer>();
        CombineInstance[] combine = new CombineInstance[meshFs.Length];
        var centerPos = GetCenter(meshFs);
        Material[] mats= new Material[meshFs.Length];
        for (int i = 0; i < meshFs.Length; i++)
        {
            combine[i].mesh = meshFs[i].sharedMesh;
            meshFs[i].transform.position = meshFs[i].transform.position - centerPos;
            combine[i].transform = meshFs[i].transform.localToWorldMatrix;
            mats[i] = meshRenders[i].sharedMaterial;
            meshRenders[i].enabled = false;
        }
        var thisMeshRender = Selection.activeTransform.GetComponent<MeshRenderer>();
        thisMeshRender.materials = mats;
        var newMesh = new Mesh();
        var thisMeshFilter = Selection.activeTransform.GetComponent<MeshFilter>();
        // combineMesh 第二个参数 true:合并生成一个大网格;  第二个参数是false：合并生成子网格；
        newMesh.CombineMeshes(combine,false);
        
        for (int i = 0; i < newMesh.subMeshCount; i++)
        {
            var triangleOne = newMesh.GetTriangles(i);
            
            
        }
        thisMeshFilter.mesh = newMesh;
    }
    
    
}
