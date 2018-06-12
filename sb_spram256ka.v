// based on https://github.com/cliffordwolf/icestorm/blob/master/icefuzz/tests/sb_spram256ka.v

module sb_spram256ka(
  input clk,
  input [13:0] addr,
  input [15:0] din,
  input wren,
  input cs,
  output [15:0] dout // not registered
);

`ifndef REAL_MEMORY

    reg [15:0] spram_data [0:(2**14)-1];

    initial begin
        $display("Loading memory...");
        $readmemb("spram.bin", spram_data);
        $display("Loading done. %04X", spram_data[0]);
    end

    always @(posedge clk) begin
        if (cs) begin
            if (wren) begin
                $display("[%0t] write addr %04X <= %04X", $time, addr, din);
                spram_data[addr] <= din;
                dout <= din;
            end else begin
                $display("[%0t] read addr %04X => %04X", $time, addr, spram_data[addr]);
                dout <= spram_data[addr];
            end
        end else begin
            $display("[%0t] idle mem", $time);
            dout <= 'X;
        end
    end

`else

SB_SPRAM256KA spram_i   // see TN1314
  (
    .ADDRESS(addr),     // Address input
    .DATAIN(din),       // Write Data input
    .MASKWREN(4'b1111), // Nibble WE control
    .WREN(wren),        // Write Enable
    .CHIPSELECT(cs),    // Enable SPRAM
    .CLOCK(clk),        // Clock input
    .STANDBY(1'b0),     // Standby Mode
    .SLEEP(1'b0),       // Sleep Mode
    .POWEROFF(1'b0),    // Switch off power source to SPRAM
    .DATAOUT(dout)      // Output Data
  );
end

`endif

endmodule
