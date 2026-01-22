using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CameraPlayerController : MonoBehaviour
{
    [SerializeField]
    private float moveSpeed;
    [SerializeField]
    private float sensitivity;
    private Vector2 turn;
    private bool locked = false;
    
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        turn = new Vector2(transform.localRotation.x, transform.localRotation.y);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.L))
        {
            locked = !locked;
        }
    }
    

    // Update is called once per frame
    void FixedUpdate()
    {
        if (locked)
            return;
        
        float yDirection = Input.GetAxisRaw("Vertical");
        float xDirection = Input.GetAxisRaw("Horizontal");

        transform.position += transform.forward * moveSpeed * Time.fixedDeltaTime * yDirection;
        transform.position += transform.right * moveSpeed * Time.fixedDeltaTime * xDirection;

        turn.x += Input.GetAxis("Mouse X") * sensitivity;
        turn.y += Input.GetAxis("Mouse Y") * sensitivity;
        transform.localRotation = Quaternion.Euler(-turn.y, turn.x, 0);
    }
}
