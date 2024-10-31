/******************************************************************************
* Copyright (C) 2024 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <inttypes.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpiops.h"
#include "xil_types.h"
#include "xil_io.h"
#include <stdbool.h>

#define STATUS_REG_OFF          0x00
#define CONTROL_REG_OFF         0x04
#define VERSION_REG_OFF         0x08
#define SCRPAD_REG_OFF          0x0C
#define KEY_CIPHER_REG_OFF      0x10
#define KEY_DECIPHER_REG_OFF    0x14
#define PLAIN_REG_OFF           0x18
#define TO_DECIPHER_REG_OFF     0x1C
#define CIPHER_REG_OFF          0x20
#define DECIPHER_REG_OFF        0x24

u_int32_t plain[4] ={0x00112233,0x44556677,0x8899aabb,0xccddeeff};
u_int32_t key[8] = {0x00010203,0x04050607,0x08090a0b,0x0c0d0e0f,0x10111213,0x14151617,0x18191a1b,0x1c1d1e1f};
u_int32_t cipher_text[4];
int main()
{
    fflush(stdout);    
    u_int32_t read_version;
    u_int32_t read_status;
    u_int32_t read_control;
    bool done_cipher = false;

    init_platform();

    read_version = Xil_In32(XPAR_IP_AES_0_BASEADDR + VERSION_REG_OFF);
    xil_printf("\nVersion register value : %x",read_version);

    for(int i = 0; i < 4; i++){
        Xil_Out32(XPAR_IP_AES_0_BASEADDR + PLAIN_REG_OFF, plain[i]);
        xil_printf("\n32bits Plain text value : %x",plain[i]);
    }

    for(int i = 0; i < 8; i++){
        Xil_Out32(XPAR_IP_AES_0_BASEADDR + KEY_CIPHER_REG_OFF, key[i]);
        xil_printf("\n32bits Cipher key value : %x",key[i]);
    }

    Xil_Out32(XPAR_IP_AES_0_BASEADDR + CONTROL_REG_OFF, 0x000000001);
    read_control = Xil_In32(XPAR_IP_AES_0_BASEADDR + CONTROL_REG_OFF);
    xil_printf("\nControl register value : %x",read_control);

    read_status = Xil_In32(XPAR_IP_AES_0_BASEADDR + STATUS_REG_OFF);
    xil_printf("\nStatus register value : %x",read_status);
    
    while (done_cipher == false) {
        Xil_Out32(XPAR_IP_AES_0_BASEADDR + CONTROL_REG_OFF, 0x000000000);
        read_status = Xil_In32(XPAR_IP_AES_0_BASEADDR + STATUS_REG_OFF);
        xil_printf("\nStatus register value : %x",read_status);
        if ((read_status && 0x00000001) == 1) {
            done_cipher = true;
        } else {
            done_cipher = false;
        }
    }

    Xil_In32(XPAR_IP_AES_0_BASEADDR + CIPHER_REG_OFF);
    for (int i = 0; i < 4; i++) {
        cipher_text[i] = Xil_In32(XPAR_IP_AES_0_BASEADDR + CIPHER_REG_OFF);
        xil_printf("\n32bits Cipher text value : %x",cipher_text[i]);
    }

    cleanup_platform();
    return 0;
}