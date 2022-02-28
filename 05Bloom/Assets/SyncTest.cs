using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SyncTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            QualitySettings.vSyncCount = 1;
            Application.targetFrameRate = 60;

        }
        else if (Input.GetKeyDown(KeyCode.D))
        {
            QualitySettings.vSyncCount = 1;
            Application.targetFrameRate = 60;
        }
    }
}
