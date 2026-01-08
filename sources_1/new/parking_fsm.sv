`timescale 1ns/1ps

module parking_fsm(
    input  logic clk,
    input  logic reset,
    
    // --- Data Path Inputs ---
    input  logic empty,             
    input  logic [1:0] head_tag,    
    
    // --- Zone Status Inputs (Busy Flags) ---
    input  logic busy_c,
    input  logic busy_s,
    input  logic busy_e,
    input  logic busy_v,
    
    // --- Control Outputs ---
    output logic pop_fifo,          
    output logic start_timer        
);

    // 1. State Encoding
    typedef enum logic [2:0] {
        DISPATCH = 3'b000,
        WAIT_C   = 3'b001,
        WAIT_S   = 3'b010,
        WAIT_E   = 3'b011,
        WAIT_V   = 3'b100,
        PROCESS  = 3'b101
    } state_t;

    state_t current_state, next_state;

    // 2. State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) 
            current_state <= DISPATCH;
        else       
            current_state <= next_state;
    end

    // 3. 3-to-8 Decoder
    logic [7:0] D;
    always_comb begin
        D = 8'b0;
        D[current_state] = 1'b1;
    end

    // 4. Output Logic (Decoder Based)
    assign pop_fifo    = D[5];
    assign start_timer = D[5];

    // 5. Next State Logic
    always_comb begin
        next_state = current_state; 

        case (current_state)
            DISPATCH: begin
                if (!empty) begin
                    case (head_tag)
                        2'b00: next_state = WAIT_C;
                        2'b01: next_state = WAIT_S;
                        2'b10: next_state = WAIT_E;
                        2'b11: next_state = WAIT_V;
                    endcase
                end
            end
            WAIT_C: if (!busy_c) next_state = PROCESS;
            WAIT_S: if (!busy_s) next_state = PROCESS;
            WAIT_E: if (!busy_e) next_state = PROCESS;
            WAIT_V: if (!busy_v) next_state = PROCESS;
            PROCESS: next_state = DISPATCH;
            default: next_state = DISPATCH;
        endcase
    end
endmodule