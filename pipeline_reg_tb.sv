`timescale 1ns/1ps

module pipeline_reg_tb;

    parameter DATA_WIDTH = 32;

    logic clk;
    logic reset_n;

    // Input interface
    logic                  in_valid;
    logic                  in_ready;
    logic [DATA_WIDTH-1:0] in_data;

    // Output interface
    logic                  out_valid;
    logic                  out_ready;
    logic [DATA_WIDTH-1:0] out_data;

    // DUT
    pipeline_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk       (clk),
        .reset_n     (reset_n),
        .in_valid  (in_valid),
        .in_ready  (in_ready),
        .in_data   (in_data),
        .out_valid (out_valid),
        .out_ready (out_ready),
        .out_data  (out_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Scoreboard
    logic [DATA_WIDTH-1:0] expected_data;
    logic                  expect_valid;

    // Monitor output
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            expect_valid <= 0;
        end else begin
            if (in_valid && in_ready) begin
                expected_data <= in_data;
                expect_valid  <= 1;
            end
            if (out_valid && out_ready) begin
                expect_valid <= 0;
            end
        end
    end

    // Assertions / checks
    always_ff @(posedge clk) begin
        if (out_valid && out_ready) begin
            if (out_data !== expected_data) begin
                $error("DATA MISMATCH! Expected=%0h Got=%0h",
                        expected_data, out_data);
            end else begin
                $display("PASS: Data %0h transferred correctly", out_data);
            end
        end
    end

    // Test sequence
    initial begin
        clk = 0;
        reset_n = 0;
        in_valid = 0;
        in_data = 0;
        out_ready = 0;

        // Reset
        #20;
        reset_n = 1;
        out_ready = 1;

        // -------------------------
        // Test 1: Simple transfer
        // -------------------------
        @(posedge clk);
        in_valid = 1;
        in_data  = 32'hA5A5_0001;

        @(posedge clk);
        in_valid = 0;

        // -------------------------
        // Test 2: Backpressure
        // -------------------------
        @(posedge clk);
        out_ready = 0;   // Stall downstream

        @(posedge clk);
        in_valid = 1;
        in_data  = 32'hDEAD_BEEF;

        @(posedge clk);
        in_valid = 0;

        repeat (3) @(posedge clk);

        out_ready = 1;   // Release backpressure

        // -------------------------
        // Test 3: Simultaneous push/pop
        // -------------------------
        @(posedge clk);
        in_valid = 1;
        in_data  = 32'h1234_5678;

        @(posedge clk);
        in_valid = 0;

        // -------------------------
        // Finish
        // -------------------------
        repeat (5) @(posedge clk);
        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
