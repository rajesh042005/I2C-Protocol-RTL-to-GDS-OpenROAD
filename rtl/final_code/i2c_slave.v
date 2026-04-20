module i2c_slave (
    input scl,

    input  sda_in,
    output reg sda_out,
    output reg sda_oe
);

parameter SLAVE_ADDR = 7'b1010111;

reg [2:0] bit_cnt = 7;
reg [7:0] shift_reg;
reg [7:0] data_reg = 8'hA5;

reg [2:0] state = 0;
reg rw;

// Start/Stop detection
reg sda_d;

always @(posedge scl) begin
    sda_d <= sda_in;
end

wire start = (sda_d == 1 && sda_in == 0);
wire stop  = (sda_d == 0 && sda_in == 1);

// FSM
localparam IDLE=0, ADDR=1, ACK1=2, DATA=3, ACK2=4;

always @(posedge scl) begin

    if (start) begin
        state <= ADDR;
        bit_cnt <= 7;
    end

    case(state)

    ADDR: begin
        shift_reg[bit_cnt] <= sda_in;

        if (bit_cnt == 0) begin
            rw <= sda_in;
            state <= ACK1;
        end else
            bit_cnt <= bit_cnt - 1;
    end

    ACK1: begin
        if (shift_reg[7:1] == SLAVE_ADDR) begin
            state <= DATA;
            bit_cnt <= 7;
        end else
            state <= IDLE;
    end

    DATA: begin
        if (!rw)
            shift_reg[bit_cnt] <= sda_in;

        if (bit_cnt == 0)
            state <= ACK2;
        else
            bit_cnt <= bit_cnt - 1;
    end

    ACK2: begin
        state <= IDLE;
    end

    endcase

    if (stop)
        state <= IDLE;
end

// SDA drive logic
always @(negedge scl) begin
    case(state)

    ACK1: begin
        if (shift_reg[7:1] == SLAVE_ADDR) begin
            sda_oe  <= 1;
            sda_out <= 0;
        end else
            sda_oe <= 0;
    end

    DATA: begin
        if (rw) begin
            sda_oe  <= 1;
            sda_out <= data_reg[bit_cnt];
        end else
            sda_oe <= 0;
    end

    ACK2: begin
        sda_oe  <= 1;
        sda_out <= 0;
    end

    default: sda_oe <= 0;

    endcase
end

endmodule
