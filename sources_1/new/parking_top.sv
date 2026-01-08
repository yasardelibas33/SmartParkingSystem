`timescale 1ns/1ps

module parking_top(
    input  logic clk,          // Basys3 100MHz Clock
    input  logic btnC,         // Reset (Center Button)
    input  logic btnU,         // Compact Car Arrival
    input  logic btnL,         // SUV Car Arrival
    input  logic btnR,         // Electric Car Arrival
    input  logic btnD,         // VIP Car Arrival
    
    output logic [15:0] led,   // Zone Status LEDs
    output logic [6:0]  seg,   // 7-Segment Cathodes
    output logic [3:0]  an,    // 7-Segment Anodes
    output logic dp            // Decimal Point
);

    // --- INTERNAL SIGNALS ---
    logic reset;
    assign reset = btnC;       // Active High Reset

    // Clock Signals
    logic tick_1hz;            
    logic blink_clk;           
    
    // Data Path Signals
    logic [1:0] push_tag;      
    logic push;               
    logic [1:0] head_tag;      
    logic pop_fifo;            
    logic empty, full;         
    
    // Control Signals
    logic start_timer;        
    logic busy_c, busy_s, busy_e, busy_v; 

    // --- 1. CLOCK DIVIDER ---
    //100_000_000 FOR SHOWING IN REAL LIFE
    //10 for testing
    clock_divider #(.MAX_COUNT(100_000_000 )) u_clk_div (
        .clk(clk),
        .reset(reset),
        .tick_1hz(tick_1hz),
        .blink_clk(blink_clk)
    );

    // --- 2. INPUT LOGIC (BUTTON EDGE DETECTION) ---
    
    logic [3:0] btn_sync, btn_prev;
    logic [3:0] btn_raw;
    assign btn_raw = {btnU, btnL, btnR, btnD}; // C, S, E, V

    always_ff @(posedge clk) begin
        if (reset) begin
            btn_sync <= 0;
            btn_prev <= 0;
            push <= 0;
            push_tag <= 0;
        end else begin
            btn_sync <= btn_raw; 
            btn_prev <= btn_sync; 
            
            push <= 0; // Default
            
            // Rising Edge Detection 
            if (btn_sync[3] && !btn_prev[3]) begin      // btnU (Compact)
                push <= 1; push_tag <= 2'b00;
            end else if (btn_sync[2] && !btn_prev[2]) begin // btnL (SUV)
                push <= 1; push_tag <= 2'b01;
            end else if (btn_sync[1] && !btn_prev[1]) begin // btnR (Electric)
                push <= 1; push_tag <= 2'b10;
            end else if (btn_sync[0] && !btn_prev[0]) begin // btnD (VIP)
                push <= 1; push_tag <= 2'b11;
            end
        end
    end

    // --- 3. FIFO (QUEUE) ---
    strict_fifo #(.DEPTH(8)) u_fifo (
        .clk(clk), .reset(reset),
        .push(push),
        .push_tag(push_tag),
        .pop(pop_fifo),
        .head_tag(head_tag),
        .empty(empty),
        .full(full)
    );

    // --- 4. FSM (CONTROLLER) ---
    parking_fsm u_fsm (
        .clk(clk), .reset(reset),
        .empty(empty),
        .head_tag(head_tag),
        .busy_c(busy_c), .busy_s(busy_s), 
        .busy_e(busy_e), .busy_v(busy_v),
        .pop_fifo(pop_fifo),
        .start_timer(start_timer)
    );

    // --- 5. TIMERS ---
    quad_timer #(.T_C(5), .T_S(8), .T_E(10), .T_V(12)) u_timer (
        .clk(clk), .reset(reset),
        .tick_1hz(tick_1hz),
        .start_timer(start_timer),
        .type_sel(head_tag),
        .busy_c(busy_c), .busy_s(busy_s), 
        .busy_e(busy_e), .busy_v(busy_v)
    );

    // --- 6. OUTPUT LOGIC: LEDS ---
    // Pattern: CCC.SSS.EEE.VVV.
    // Solid ON (1) -> Available (!busy)
    // Blinking     -> Occupied (busy)
    
    // Helper function for blink logic
    function logic led_state(input logic busy, input logic blink);
        return busy ? blink : 1'b1;
    endfunction

    always_comb begin
        led = 16'b0; // Default off
        
        // Compact LEDs (15, 14, 13)
        led[15] = led_state(busy_c, blink_clk);
        led[14] = led_state(busy_c, blink_clk);
        led[13] = led_state(busy_c, blink_clk);
        
        // SUV LEDs (11, 10, 9)
        led[11] = led_state(busy_s, blink_clk);
        led[10] = led_state(busy_s, blink_clk);
        led[9]  = led_state(busy_s, blink_clk);
        
        // Electric LEDs (7, 6, 5)
        led[7] = led_state(busy_e, blink_clk);
        led[6] = led_state(busy_e, blink_clk);
        led[5] = led_state(busy_e, blink_clk);
        
        // VIP LEDs (3, 2, 1)
        led[3] = led_state(busy_v, blink_clk);
        led[2] = led_state(busy_v, blink_clk);
        led[1] = led_state(busy_v, blink_clk);
        
        // Dots are always OFF (0) at indices 12, 8, 4, 0
    end

    // --- 7. OUTPUT LOGIC: 7-SEGMENT DISPLAY ---
    logic [2:0] total_cars;
    assign total_cars = busy_c + busy_s + busy_e + busy_v;

    assign an = 4'b1110; 
    assign dp = 1;       

    // 7-Segment Decoder 
    always_comb begin
        case (total_cars)
            3'd0: seg = 7'b1000000; // 0
            3'd1: seg = 7'b1111001; // 1
            3'd2: seg = 7'b0100100; // 2
            3'd3: seg = 7'b0110000; // 3
            3'd4: seg = 7'b0011001; // 4
            default: seg = 7'b1111111; 
        endcase
    end

endmodule