`ifndef CHI_CHAN_
  `define CHI_CHAN_

`include "chi_noc_def.v"

interface chi_chan
  import `CHI_PCKG::*;
#(
  parameter type DATA_T = `REQ_FLIT_T
);

  logic  flit_pend;
  logic  flit_v;
  DATA_T flit;

  logic lcrd_v;

  modport tx(
    output flit_pend,
    output flit_v,
    output flit,
    input  lcrd_v
  );

  modport rx(
    input  flit_pend,
    input  flit_v,
    input  flit,
    output lcrd_v
  );

endinterface : chi_chan

`endif // CHI_CHAN_




