
`default_nettype none

module spi_peripheral (
    input  wire       SCLK,      // clock
    input  wire       COPI,
    input  wire       nCS,
    input  wire       rst_n,
    output  reg [7:0] en_reg_out_7_0,
    output  reg [7:0] en_reg_out_15_8,
    output  reg [7:0] en_reg_pwm_7_0,
    output  reg [7:0] en_reg_pwm_15_8,
    output  reg [7:0] pwm_duty_cycle
);

reg [3:0] index;
reg [15:0] data;

wire r_w;
reg [6:0] address;
reg [7:0] acc_data;

assign r_w      = data[15];
assign address  = data[14:8];
assign acc_data = data[7:0];

reg nCS_sync1, nCS_sync2, nCS_p;
reg transaction_processed, transaction_ready;

always @(posedge SCLK or negedge rst_n) begin
    if (!rst_n) begin
        en_reg_out_7_0    <= 0;
        en_reg_out_15_8   <= 0;
        en_reg_pwm_7_0    <= 0;
        en_reg_pwm_15_8   <= 0;
        pwm_duty_cycle    <= 0;
        transaction_ready <= 1'b0;
        index             <= 4'b0;
        data              <= 16'b0;
        // omitted code
    end else begin
        nCS_sync1 <= nCS;
        nCS_sync2 <= nCS_sync1;
        nCS_p     <= nCS_sync2;
    
        // When nCS goes high (transaction ends), validate the complete transaction
        if (nCS_sync2 && ~nCS_p) begin
            transaction_ready <= 1'b1;
            index <= 4'b0;
        end else if (transaction_processed) begin
            transaction_ready <= 1'b0;
        end else if (~nCS_sync2) begin
            data[15 - index] <= COPI;
            index <= index + 1;
            if(nCS_p) begin
                index <= 4'b0;
            end
            // omitted code
        end
    end
end

// Update registers only after the complete transaction has finished and been validated
always @(posedge SCLK or negedge rst_n) begin
    if (!rst_n) begin
        en_reg_out_7_0    <= 0;
        en_reg_out_15_8   <= 0;
        en_reg_pwm_7_0    <= 0;
        en_reg_pwm_15_8   <= 0;
        pwm_duty_cycle    <= 0;
        transaction_processed <= 1'b0;
    end else if (transaction_ready && !transaction_processed) begin
        // Transaction is ready and not yet processed
        if (r_w) begin
            if(address == 7'b0) begin
                en_reg_out_7_0  <= acc_data;
            end else if (address == 7'b0000001) begin
                en_reg_out_15_8 <= acc_data;
            end else if (address == 7'b0000010) begin
                en_reg_pwm_7_0  <= acc_data;
            end else if (address == 7'b0000011) begin
                en_reg_pwm_15_8 <= acc_data;
            end else if (address == 7'b0000100) begin
                pwm_duty_cycle  <= acc_data;
            end
        end
        // Set the processed flag
        transaction_processed <= 1'b1;
    end else if (!transaction_ready && transaction_processed) begin
        // Reset processed flag when ready flag is cleared
        transaction_processed <= 1'b0;
    end
end

endmodule