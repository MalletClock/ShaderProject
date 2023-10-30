using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor.Rendering;
using UnityEngine;

[ExecuteAlways]
public class SimpleMovableCube : MonoBehaviour
{

    [SerializeField] private Material ProximityMaterial;
    [SerializeField] private Material ProximityMaterial2;

    private static int PlayerPosID = Shader.PropertyToID("_PlayerPosition");


    void Update()
    {

        Vector3 movement = Vector3.zero;

        if (Input.GetKey(KeyCode.W))
        {
            movement += Vector3.forward;
        }
        if (Input.GetKey(KeyCode.A))
        {
            movement += Vector3.left;
        }
        if (Input.GetKey(KeyCode.S))
        {
            movement += Vector3.back;
        }
        if (Input.GetKey(KeyCode.D))
        {
            movement += Vector3.right;
        }
        if (Input.GetKey(KeyCode.Space))
        {
            movement += Vector3.up;
        }
        if (Input.GetKey(KeyCode.LeftControl))
        {
            movement += Vector3.down;
        }

        transform.Translate(Time.deltaTime * 5 * movement.normalized);

        ProximityMaterial.SetVector(PlayerPosID, transform.position);
        ProximityMaterial2.SetVector(PlayerPosID, transform.position);

    }
}
