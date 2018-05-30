/* verilator lint_off UNUSED */

module abc (
        // parameter bla = 2,
        input clk,
        input rst,
        input [1:0] a,
        //output reg [2:0] b
        output [2:0] b
    );


    wire [7:0] sine [0:3];

    // assign blaa = { 1'0 };


    initial begin
        $display("[%0t] Model running...\n", $time);

        $readmemb("hmm.txt", sine);
    end

    logic what;

    reg [9:0] line_r = 0;

    // 625 lines and 25 frames

    reg [1:0] subpixel_r = 0;





    reg [7:0] b_r = 0;

    wire enable = 1;
    // reg [4:0] reverse;

    // reg [7:0] mem [4] wow;

    // task SUM_TASK();
    //     reg [7:0] sum_temp; // local variable
    //     sum_temp   = in1 + in2 + in3;
    //     result    <= sum_temp;
    //     result_p1 <= sum_temp + 1;
    // endtask

    wire video;









    // 135° and 225° from line to line
    always @(*) begin : pal_subpixel_phase
        case (line_r[0])
            0: case (subpixel_r)
                0: video = 0;
                1: video = 0;
                2: video = 1;
                3: video = 1;
            endcase
            1: case (subpixel_r)
                0: video = 1;
                1: video = 0;
                2: video = 0;
                3: video = 1;
            endcase
        endcase
    end

    reg [8:0] pixel_clock_r = 0;

    always @(posedge clk) begin : subpixel_counter
        subpixel_r <= subpixel_r + 1;
        if (subpixel_r == 3) begin
            pixel_clock_r <= pixel_clock_r + 1;
            if (pixel_clock_r == 284 - 1) begin
                pixel_clock_r <= 0;
                line_r <= line_r + 1;
                if (line_r == 1) begin
                    $finish;
                end
                if (line_r == 625 - 1) begin
                    line_r <= 0;
                end
            end
        end
    end

// The whole line lasts 64 µs but the visible part is 51.9 µs.

// 720 pixels x 576 lines

// 1 / ((4 * 4433618.75) Hz) * 4 * 284 = 64.0560265 microseconds

// let's do... 852x576

// Line period 64 us (Micro-seconds)
// Line blanking 12.05 +- 0.25 us
// Line sync 4.7 +- 0.1 us
// Front porch: 1.65 +- 0.1 us
// Burst start 5.6 +- 0.1 us after sync start.
// Burst 10 +- 1 cycles

    always @(*) begin : blaat
        reg [7:0] x = (b_r + 1);

        if (rst) begin
            b = 3'b000;
        end else begin
            b = x[7:5];
        end
    end

    // always @(posedge clk, posedge rst) begin
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            // reset
            b_r <= 0;
        end else if (enable) begin
            b_r <= b_r + 1;

            if (b_r >= 100) begin
                //$display("[%0t] blaat\n", $time);
                // This write is a magic value the Makefile uses to make sure the test completes successfully.
                // $write("*-* All Finished *-*\n");
                //$finish;
                b_r <= 0;
            end
        end
    end

endmodule
