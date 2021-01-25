/*------------------------------------------------------------------------------
* Copyright (C) 2018, 2019, SemiDynamics Technology Services, S.L.U.  
* The copyright to the computer program(s) herein is the property of
* SemiDynamics Technology Services, S.L.U. All Rights Reserved.  NOTICE: the
* intellectual and technical concepts contained herein are proprietary to
* SemiDynamics Technology Services, S.L.U. and are protected by trade secret or
* copyright law.  Dissemination of this information and use or reproduction of
* this material is strictly forbidden unless prior written permission is
* obtained from SemiDynamics Technology Services, S.L.U. The program(s) may be
* used and/or reproduced only with the written permission of SemiDynamics
* Technology Services, S.L.U. and in accordance with the regulations under the
* Horizon 2020 Grant Agreement and the terms and conditions of MontBlanc 2020
* Consortium Agreement under which the program(s) have been distributed. Unless
* required by applicable law or agreed in writing, the program(s) is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied.
*-------------------------------------------------------------------------------
*   Author:         Jordi Cortina
*   Email:          jordi.cortina@semidynamics.com
*   Date:           06/06/2019
*-------------------------------------------------------------------------------
*   Title:          L2 Package
*   Description:    
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

package l2_pkg;

    // Input request type enumeration
    localparam SPR                  = 0 ,
               FLR                  = 1 ,
               L1R                  = 2 ;

    // L1 Request Opcode Spec
    localparam L1_LD                = 3'b000;
    localparam L1_LX                = 3'b001;
    localparam L1_ST                = 3'b010;
    localparam L1_SX                = 3'b011;
    localparam L1_ED                = 3'b1??;

    localparam L1_OPC_EVICT_BIT     = 2     ;

    // L2 Status Bits
    localparam I_ST                 = 2'b00 ;
    localparam S_ST                 = 2'b01 ;
    localparam E_ST                 = 2'b10 ;
    localparam M_ST                 = 2'b11 ;

    // Snoop REQ Opcodes
    localparam SNPSHARED	    = 5'h01 ;
    localparam SNPCLEAN	            = 5'h02 ;
    localparam SNPONCE	            = 5'h03 ;
    localparam SNPNOTSHAREDDIRTY    = 5'h04 ;
    localparam SNPUNIQUE	    = 5'h07 ;
    localparam SNPCLEANSHARED	    = 5'h08 ;
    localparam SNPCLEANINVALID	    = 5'h09 ;
    localparam SNPMAKEINVALID	    = 5'h0A ;
    localparam SNPSHAREDFWD	    = 5'h11 ;
    localparam SNPCLEANFWD	    = 5'h12 ;
    localparam SNPONCEFWD	    = 5'h13 ;
    localparam SNPNOTSHAREDDIRTYFWD = 5'h14 ;
    localparam SNPUNIQUEFWD	    = 5'h17 ;

    // NoC Requests
    localparam NOC_RPC_W = 3    ; // Response Channel Width
    localparam NOC_OPC_W = 6    ; // NoC Opcode Width
    localparam NOC_RSP_W = 3    ; // NoC Resp Field Width
    localparam NOC_DAT_W = 256  ; // NoC Data Field Width

    // Response Channels
    typedef enum logic [NOC_RPC_W-1:0] {
        NORP    = 'b000 ,   // No Response
        REQT    = 'b001 ,   // Request Channel
        SRSP    = 'b010 ,   // Snoop Response Channel
        WDAT    = 'b011 ,   // Write Data Channel
        CRSP    = 'b100     // Completion Response Channel
    } rsp_ch_t;
    
    // NoC Opcodes
    // NoC REQ Channel Opcodes
    localparam  CLUNIQUE    = 'h0B,
                MKUNIQUE    = 'h0C,
                WRBACKFULL  = 'h1B,
                RDUNIQUE    = 'h07,
                RDSHARED    = 'h01;
    // NoC SRSP Channel Opcodes
    localparam  SNPRESP     = 'h01;
    localparam  SNPRSFW     = 'h09; // Forward type Snoop no Data
    localparam  SNPRFWD     = 'h06; // Forward type Snoop with Data
    // NoC DAT Channel Opcodes
    localparam  COMPDATA    = 'h04;

    // Resp types
    typedef enum logic [NOC_RSP_W-1:0] {
        ST_I        = 'b000,    // I
        ST_UCD      = 'b010,    // E
        ST_SC       = 'b001,    // S
        ST_I_PD     = 'b100,
        ST_UCD_PD   = 'b110,
        ST_SC_PD    = 'b101
    } noc_resp_t;


endpackage : l2_pkg
