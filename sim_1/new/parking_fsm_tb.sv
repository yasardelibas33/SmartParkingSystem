`timescale 1ns/1ps

module tb_parking_top;

    // Inputs to DUT (Basys3 Buttons & Clock)
    logic clk;
    logic btnC; // Reset
    logic btnU; // Compact
    logic btnL; // SUV
    logic btnR; // Electric
    logic btnD; // VIP

    // Outputs from DUT (Basys3 LEDs & 7-Segment)
    logic [15:0] led;
    logic [6:0]  seg;
    logic [3:0]  an;
    logic dp;

    // Instantiate the Top Module
        parking_top dut (
        .clk(clk),
        .btnC(btnC),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .led(led),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

    // Clock Generation (100MHz = 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Button Press Task (Simulate physical button press)
    task press_btn(input string btn_name);
        begin
            $display("Time %t: Button Pressed - %s", $time, btn_name);
            case(btn_name)
                "C": btnC = 1;
                "U": btnU = 1;
                "L": btnL = 1;
                "R": btnR = 1;
                "D": btnD = 1;
            endcase
            #100; 
            btnC = 0; btnU = 0; btnL = 0; btnR = 0; btnD = 0;
            #100; 
        end
    endtask

    // Test 
    initial begin
        // 1. Initial State
        $display("--- Simulation is starting ---");
        btnC = 0; btnU = 0; btnL = 0; btnR = 0; btnD = 0;
        
        // Reset System
        #50;
        press_btn("C"); 
        #50;

        // 2. Test Compact Car Arrival
        
        press_btn("U"); // Compact
        #200; 
        
        // 3. Test Queueing Logic 
        press_btn("L"); // SUV
        #100;
        
        // Electric 
        press_btn("R"); // Electric
        #100;

        
        $display("--- Waiting for the timers ---");
        #2000; 

        // 5. VIP Car Arrival
        press_btn("D"); // VIP
        #500;

        $display("--- Simulation is done ---");
        $finish;
    end

endmodule