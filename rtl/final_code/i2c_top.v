module i2c_top (
    input clk,
    input rst,
    input enable,
    input rw,
    input [6:0] addr,
    input [7:0] data_in,
    output [7:0] data_out
);

wire scl;

// Split SDA signals
wire sda_master_out, sda_master_oe;
wire sda_slave_out,  sda_slave_oe;
wire sda_in;

// MASTER
i2c_master master (
    .clk(clk),
    .rst(rst),
    .addr(addr),
    .data_in(data_in),
    .enable(enable),
    .rw(rw),
    .data_out(data_out),
    .busy(),
    .scl(scl),

    .sda_in(sda_in),
    .sda_out(sda_master_out),
    .sda_oe(sda_master_oe)
);

// SLAVE
i2c_slave slave (
    .scl(scl),

    .sda_in(sda_in),
    .sda_out(sda_slave_out),
    .sda_oe(sda_slave_oe)
);

// OPEN-DRAIN RESOLUTION
assign sda_in =
    ( (sda_master_oe && (sda_master_out == 0)) ||
      (sda_slave_oe  && (sda_slave_out  == 0)) )
    ? 1'b0 : 1'b1;

endmodule
