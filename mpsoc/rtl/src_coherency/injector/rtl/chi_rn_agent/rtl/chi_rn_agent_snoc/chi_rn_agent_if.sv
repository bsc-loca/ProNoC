/* =============================================================================
*
* Copyright (c) 2018 EXTOLL GmbH
* This file is confidential and may not be distributed.
* All rights reserved.
*
* EXTOLL GmbH
* Rheinvorlandstrasse 5
* 68159 Mannheim
* Germany
* www.extoll.de
*
* Author(s)  :     Niels Burkhardt
*
* Create Date:   18.03.2019
* Version    :   0.5
* Description:   Definition of the NoC device interface based on
*                AMBA 5 CHI.
*
*                Interface specification can be found in chapter 12.7 and 12.8
*
*                The EPAC NoC interface assumes a node ID width of 7 bits as
*                well as a address width of 44 bits.
*
*
* ============================================================================*/

import chi_rn_params_pkg::*;

/*******************************************************************************
*
* Request channel interface
*
* See AMBA 5 CHI specification chapter 12.7.1 for more details.
*
*******************************************************************************/
interface chi_req_chan();
  logic       flit_pend;
  logic       flit_v;
  chi_reqflit_pkt_t  flit;
  logic       lcrd_v;

  modport tx (
    output flit_pend, flit_v, flit,
    input  lcrd_v
  );

  modport rx (
    input  flit_pend, flit_v, flit,
    output lcrd_v
  );
endinterface

/*******************************************************************************
 *
 * Response channel interface
 *
 * See AMBA 5 CHI specification chapter 12.7.2 for more details.
 *
 ******************************************************************************/
interface chi_rsp_chan();
  logic       flit_pend;
  logic       flit_v;
  chi_rspflit_pkt_t  flit;
  logic       lcrd_v;

  modport tx (
    output flit_pend, flit_v, flit,
    input  lcrd_v
  );

  modport rx (
    input  flit_pend, flit_v, flit,
    output lcrd_v
  );
endinterface

/*******************************************************************************
 *
 * Snoop channel interface
 *
 * See AMBA 5 CHI specification chapter 12.7.3 for more details.
 *
 ******************************************************************************/
interface chi_snp_chan();
  logic       flit_pend;
  logic       flit_v;
  chi_snpflit_pkt_t  flit;
  logic       lcrd_v;

  modport tx (
    output flit_pend, flit_v, flit,
    input  lcrd_v
  );

  modport rx (
    input  flit_pend, flit_v, flit,
    output lcrd_v
  );
endinterface

/*******************************************************************************
 *
 * Data channel interface
 *
 * See AMBA 5 CHI specification chapter 12.7.4 for more details.
 *
 ******************************************************************************/
interface chi_dat_chan();
  logic       flit_pend;
  logic       flit_v;
  chi_datflit_snoc_pkt_t  flit;
  logic       lcrd_v;

  modport tx (
    output flit_pend, flit_v, flit,
    input  lcrd_v
  );

  modport rx (
    input  flit_pend, flit_v, flit,
    output lcrd_v
  );
endinterface
