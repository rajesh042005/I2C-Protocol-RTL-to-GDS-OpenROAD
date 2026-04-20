module i2c_master (
    input clk,
    input rst,
    input [6:0] addr,
    input [7:0] data_in,
    input enable,
    input rw,

    output reg [7:0] data_out,
    output reg busy,

    output scl,

    input  sda_in,
    output reg sda_out,
    output reg sda_oe
);

// Clock divider
parameter DIV = 250;

reg [15:0] clk_cnt;
reg scl_int;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_cnt <= 0;
        scl_int <= 1;
    end else begin
        if (clk_cnt == DIV-1) begin
            clk_cnt <= 0;
            scl_int <= ~scl_int;
        end else
            clk_cnt <= clk_cnt + 1;
    end
end

// SCL control
reg scl_en;
assign scl = (scl_en) ? scl_int : 1'b1;

// FSM
localparam IDLE=0, START=1, ADDR=2, ACK1=3, DATA=4, ACK2=5, STOP=6;

reg [2:0] state;
reg [2:0] bit_cnt;
reg [7:0] shift_reg;

always @(posedge scl_int or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        busy <= 0;
        scl_en <= 0;
        sda_oe <= 1;
        sda_out <= 1;
    end else begin
        case(state)

        IDLE: begin
            busy <= 0;
            scl_en <= 0;
            sda_oe <= 1;
            sda_out <= 1;

            if (enable) begin
                busy <= 1;
                shift_reg <= {addr, rw};
                bit_cnt <= 7;
                state <= START;
            end
        end

        START: begin
            sda_out <= 0;   // START condition
            sda_oe  <= 1;
            scl_en  <= 0;
            state   <= ADDR;
        end

        ADDR: begin
            scl_en  <= 1;
            sda_oe  <= 1;
            sda_out <= shift_reg[bit_cnt];

            if (bit_cnt == 0)
                state <= ACK1;
            else
                bit_cnt <= bit_cnt - 1;
        end

        ACK1: begin
            sda_oe <= 0; // release line
            if (sda_in == 0) begin
                bit_cnt <= 7;
                shift_reg <= data_in;
                state <= DATA;
            end else
                state <= STOP;
        end

        DATA: begin
            scl_en <= 1;

            if (rw) begin
                sda_oe <= 0;
                data_out[bit_cnt] <= sda_in;
            end else begin
                sda_oe <= 1;
                sda_out <= shift_reg[bit_cnt];
            end

            if (bit_cnt == 0)
                state <= ACK2;
            else
                bit_cnt <= bit_cnt - 1;
        end

        ACK2: begin
            sda_oe <= 0;
            state <= STOP;
        end

        STOP: begin
            scl_en <= 0;
            sda_oe <= 1;
            sda_out <= 1; // STOP condition
            state <= IDLE;
        end

        endcase
    end
end

endmodule
