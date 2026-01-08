module strict_fifo #(
    parameter int DEPTH = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic push,
    input  logic [1:0] push_tag, 
    input  logic pop,            
    output logic [1:0] head_tag, 
    output logic empty,
    output logic full
);
    logic [1:0] queue [DEPTH-1:0];
    logic [$clog2(DEPTH):0] count;
    
    // Write Pointer 
    
    assign empty = (count == 0);
    assign full  = (count == DEPTH);
    assign head_tag = queue[0]; // Strict FIFO

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            for (int i=0; i<DEPTH; i++) queue[i] <= 0;
        end else begin
            // POP 
            if (pop && !empty) begin
                for (int i=0; i<DEPTH-1; i++) begin
                    queue[i] <= queue[i+1];
                end
                if (!push) count <= count - 1;
            end
            
            // PUSH
            if (push && !full) begin
                if (pop && !empty) 
                    queue[count-1] <= push_tag; 
                else begin
                    queue[count] <= push_tag;
                    count <= count + 1;
                end
            end
        end
    end
endmodule