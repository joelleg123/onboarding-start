
`default_nettype none

module spi_peripheral (
    input  wire       SCLK,      // clock
    input  wire       COPI,
    input  wire       nCS,
    input  wire       rst_n,
    output  wire [7:0] en_reg_out_7_0,
    output  wire [7:0] en_reg_out_15_8,
    output  wire [7:0] en_reg_pwm_7_0,
    output  wire [7:0] en_reg_pwm_15_8,
    output  wire [7:0] pwm_duty_cycle
);

reg [3:0] index;
reg [15:0] data;

reg nCS_sync1, nCS_sync2;
reg transaction_processed, transaction_ready;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        en_reg_out_7_0    <= 0;
        en_reg_out_15_8   <= 0;
        en_reg_pwm_7_0    <= 0;
        en_reg_pwm_15_8   <= 0;
        pwm_duty_cycle    <= 0;
        transaction_ready <= 1'b0;
        // omitted code
    end else if (nCS_sync2 == 1'b0) begin
        // omitted code
    end else begin
    
        // When nCS goes high (transaction ends), validate the complete transaction
        if (nCS_posedge) begin
            transaction_ready <= 1'b1;
        end else if (transaction_processed) begin
            // Clear ready flag once processed
            transaction_ready <= 1'b0;
        end


        // omitted code
    end
end

// Update registers only after the complete transaction has finished and been validated
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        en_reg_out_7_0    <= 0;
        en_reg_out_15_8   <= 0;
        en_reg_pwm_7_0    <= 0;
        en_reg_pwm_15_8   <= 0;
        pwm_duty_cycle    <= 0;
        transaction_processed <= 1'b0;
    end else if (transaction_ready && !transaction_processed) begin
        // Transaction is ready and not yet processed
        // omitted code
        // Set the processed flag
        transaction_processed <= 1'b1;
    end else if (!transaction_ready && transaction_processed) begin
        // Reset processed flag when ready flag is cleared
        transaction_processed <= 1'b0;
    end
end

endmodule