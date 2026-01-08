module quad_timer #(
    parameter int T_C = 50, 
    parameter int T_S = 80,
    parameter int T_E = 100,
    parameter int T_V = 120
)(
    input  logic clk,
    input  logic reset,
    input  logic tick_1hz,      
    input  logic start_timer,  
    input  logic [1:0] type_sel,
    output logic busy_c,
    output logic busy_s,
    output logic busy_e,
    output logic busy_v
);
    
    integer cnt_c, cnt_s, cnt_e, cnt_v;

    // Busy logic
    assign busy_c = (cnt_c > 0);
    assign busy_s = (cnt_s > 0);
    assign busy_e = (cnt_e > 0);
    assign busy_v = (cnt_v > 0);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt_c <= 0; cnt_s <= 0; cnt_e <= 0; cnt_v <= 0;
        end else begin
            // Start Logic 
            if (start_timer) begin
                case (type_sel)
                    2'b00: cnt_c <= T_C;
                    2'b01: cnt_s <= T_S;
                    2'b10: cnt_e <= T_E;
                    2'b11: cnt_v <= T_V;
                endcase
            end
            
            // Count Down Logic 
            if (tick_1hz) begin
                if (cnt_c > 0) cnt_c <= cnt_c - 1;
                if (cnt_s > 0) cnt_s <= cnt_s - 1;
                if (cnt_e > 0) cnt_e <= cnt_e - 1;
                if (cnt_v > 0) cnt_v <= cnt_v - 1;
            end
        end
    end
endmodule