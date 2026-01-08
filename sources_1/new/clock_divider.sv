`timescale 1ns / 1ps
module clock_divider #(
    parameter int MAX_COUNT = 100_000_000 // 100 MHz -> 1 Hz
)(
    input  logic clk,
    input  logic reset,
    output logic tick_1hz,   // 1 sec pulse for timers
    output logic blink_clk   // Slow clock for LEDs
);
    integer counter;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            tick_1hz <= 0;
        end else begin
            if (counter == MAX_COUNT - 1) begin
                counter <= 0;
                tick_1hz <= 1; // 1 cycle pulse
            end else begin
                counter <= counter + 1;
                tick_1hz <= 0;
            end
        end
    end
    
    // Use the 25th bit for approx 1.5 Hz blinking (100MHz / 2^26)
    assign blink_clk = counter[25]; 
endmodule
