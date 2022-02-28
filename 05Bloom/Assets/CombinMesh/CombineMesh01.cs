using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CombineMesh01 : MonoBehaviour
{
    void Start()
    {
        MeshFilter[] meshFilter = gameObject.GetComponentsInChildren<MeshFilter>();
        CombineInstance[] combine = new CombineInstance[meshFilter.Length];
        MeshRenderer[] mrs = gameObject.GetComponentsInChildren<MeshRenderer>();
        // int mats = 0;
        // for (int i = 0; i < mrs.Length; i++)
        // {
        //     var one = mrs[i];
        //     var matCount = one.materials.Length;
        //     mats += matCount;
        // }
        Material[] mts = new Material[mrs.Length];
        for (int i = 0; i < meshFilter.Length; i++)
        {
            var mfOne = meshFilter[i];
            combine[i].mesh = mfOne.sharedMesh;
            combine[i].transform = mfOne.transform.localToWorldMatrix;
            //mfOne.gameObject.SetActive(false);
            mrs[i].enabled = false;
            mts[i] = mrs[i].sharedMaterial;
        }
        
        Mesh newMesh = new Mesh();
        newMesh.CombineMeshes(combine,false);
        var thisMeshRender = gameObject.GetComponent<MeshRenderer>();
        gameObject.GetComponent<MeshFilter>().mesh = newMesh;
        thisMeshRender.enabled = true;
        thisMeshRender.sharedMaterials = mts;
    }
}
