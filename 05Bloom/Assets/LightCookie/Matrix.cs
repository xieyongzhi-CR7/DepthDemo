using UnityEngine;

public class Matrix : MonoBehaviour
{
    // build a matrix from a transform.
    Matrix4x4 matrix = new Matrix4x4();

    /// Build a matrix from a transform.
    void Start()
    {
        matrix.SetColumn(0, new Vector3(1,1,1));
        matrix.SetColumn(1, new Vector3(2,2,2));
        matrix.SetColumn(2, new Vector3(3,3,3));
        var p = transform.position;
        var colmn2 = matrix.GetColumn(2);
        matrix.SetColumn(3, new Vector4(p.x, p.y, p.z, 1));
        
    }
}