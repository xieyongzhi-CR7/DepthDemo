using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;    
#endif

public class combineMesh : MonoBehaviour
{
    // 设置烘焙贴图的index
    public int lightMapIndex = -1;
    // public GameObject Sphere;
    // public GameObject Capsual03;
    // public GameObject Cylinder04;
    // public GameObject Cylinder05;
    public void Awake()
    {
        if (lightMapIndex >=0)
        {
            if (TryGetComponent<MeshRenderer>(out var m))
            {
                m.lightmapIndex = lightMapIndex;
            }
        }
    }

    private void Start()
    {
        List<GameObject>gameObjects = new List<GameObject>();
        // gameObjects.Add(Sphere);
        // gameObjects.Add(Capsual03);
        // gameObjects.Add(Cylinder04);
        // gameObjects.Add(Cylinder05);
        var mesh = AssetDatabase.LoadAssetAtPath<Mesh>("Assets/Combine.asset");
        for (int i = 0; i < mesh.subMeshCount; i++)
        {
            //gameObjects[i].GetComponent<MeshFilter>().sharedMesh = mesh.GetSubMesh(i);
        }
        
    }

    public void Update()
    {
        if (Input.GetKey(KeyCode.A))
        {
            var mesh = AssetDatabase.LoadAssetAtPath<Mesh>("Assets/Combine.asset");
            if (mesh== null)
            {
                Debug.LogError("mesh error");
            }
            else
            {
                Debug.LogError("mesh load over");
            }
        }
    }


#if UNITY_EDITOR

    [MenuItem("测试/CombineMesh")]
    static void StartCombineMesh()
    {
        if (Selection.activeObject)
        {
            MeshFilter[] meshFilters = Selection.activeTransform.GetComponentsInChildren<MeshFilter>();
            Material material = null;
            int i = 0;
            int lightMap = -1;
            CombineInstance[] combine = new CombineInstance[meshFilters.Length];
            var center = GetCenter(meshFilters);
            while (i<meshFilters.Length)
            {
                var meshRenderer = meshFilters[i].GetComponent<MeshRenderer>();
                if (material ==null)
                {
                    material = meshRenderer.sharedMaterial;
                }
                if (material != meshRenderer.sharedMaterial)
                {
                    Debug.LogError("材质不同，不能合并");
                    return;
                }

                if (lightMap.Equals(-1))
                {
                    lightMap = meshRenderer.lightmapIndex;
                }

                if (!lightMap.Equals(meshRenderer.lightmapIndex))
                {
                    Debug.LogError("存在不同的光照贴图，不与合并");
                    return;
                }
                // CombineInstance  的结构是啥
                combine[i].mesh = meshFilters[i].sharedMesh;
                // 记录参与合批的lightmapOffset
                combine[i].lightmapScaleOffset = meshRenderer.lightmapScaleOffset;
                //
                Matrix4x4 matrix4X4 = meshFilters[i].transform.localToWorldMatrix;
                matrix4X4.m03 -= center.x;
                matrix4X4.m13 -= center.y;
                matrix4X4.m23 -= center.z;
                combine[i].transform = matrix4X4;
                i++;
            }
            var go = new GameObject("combine",typeof(MeshFilter),typeof(MeshRenderer));
            go.transform.position = center;
            go.AddComponent<combineMesh>().lightMapIndex = lightMap;
            
            var mesh = new Mesh();
            mesh.CombineMeshes(combine,true,true,true);
            // 合并会生成uv3  ，我们不需要可以这样删除
            mesh.uv3 = null;
            AssetDatabase.CreateAsset(mesh,"Assets/combine.asset");
            go.GetComponent<MeshFilter>().sharedMesh = mesh;
            go.GetComponent<MeshRenderer>().sharedMaterial = material;
            if (go)
            {
                PrefabUtility.SaveAsPrefabAssetAndConnect(go, Application.dataPath + "/combine.prefab",
                    InteractionMode.AutomatedAction);
            }
        }        
    }

    static Vector3 GetCenter(Component[] components)
    {
        if (components!=null && components.Length > 0)
        {
            Vector3 min = components[0].transform.position;
            Vector3 max = min;
            foreach (var comp in components)
            {
                min = Vector3.Min(min, comp.transform.position);
                max = Vector3.Max(max, comp.transform.position);
            }
            return min + ((max - min) / 2);
        }
        return Vector3.zero;
    }
#endif
}
