
`default_nettype none

module spi_peripheral (
    input  wire       SCLK,      // clock
    input  wire       COPI,
    input  wire       nCS,
    input  wire       rst_n,
    input  wire       clk,
    output  reg [7:0] en_reg_out_7_0,
    output  reg [7:0] en_reg_out_15_8,
    output  reg [7:0] en_reg_pwm_7_0,
    output  reg [7:0] en_reg_pwm_15_8,
    output  reg [7:0] pwm_duty_cycle
);


reg [1:0] sclk_sy, nCS_sy, copi_sy;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sclk_sy <= 2'b00;
        nCS_sy  <= 2'b11; 
        copi_sy <= 2'b00;
    end else begin
        sclk_sy <= {sclk_sy[0], SCLK};
        nCS_sy  <= { nCS_sy[0],  nCS};
        copi_sy <= {copi_sy[0], COPI};
    end
end

wire sclk_s = sclk_sy[1];
wire nCS_s  = nCS_sy[1];
wire copi_s = copi_sy[1];

wire sclk_r = (sclk_sy == 2'b01);
wire nCS_r  = (nCS_sy  == 2'b01);
wire nCS_f  = (nCS_sy  == 2'b10);

reg [3:0] index;
reg [15:0] data;

wire r_w = data[15];
wire [6:0] address = data[14:8];
wire [7:0] acc_data = data[7:0];

reg transaction_processed, transaction_ready;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        transaction_ready <= 1'b0;
        index             <= 4'b0;
        data              <= 16'b0;
    end else begin
    
        // When nCS goes high (transaction ends), validate the complete transaction
        if (nCS_r) begin
            transaction_ready <= 1'b1;
            index <= 4'b0;
        end else if (transaction_processed) begin
            transaction_ready <= 1'b0;
        end
        
        if (nCS_f) begin
            index <= 4'b0;
            data <= 16'b0;
        end else if (~nCS_s && sclk_r) begin
            data[15 - index] <= copi_s;
            index <= index + 1;
        end
    end
end

// Update registers only after the complete transaction has finished and been validated
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        transaction_processed <= 1'b0;
        en_reg_out_7_0    <= 0;
        en_reg_out_15_8   <= 0;
        en_reg_pwm_7_0    <= 0;
        en_reg_pwm_15_8   <= 0;
        pwm_duty_cycle    <= 0;
    end else if (transaction_ready && !transaction_processed) begin
        // Transaction is ready and not yet processed
        transaction_processed <= 1'b1;
        if (r_w) begin
            case (address)
                7'b0000000: en_reg_out_7_0  <= acc_data;
                7'b0000001: en_reg_out_15_8 <= acc_data;
                7'b0000010: en_reg_pwm_7_0  <= acc_data;
                7'b0000011: en_reg_pwm_15_8 <= acc_data;
                7'b0000100: pwm_duty_cycle  <= acc_data;
            endcase
        end
    end else if (!transaction_ready && transaction_processed) begin
        // Reset processed flag when ready flag is cleared
        transaction_processed <= 1'b0;
    end
end

endmodule