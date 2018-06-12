module top(
	input rst,
    input clk,

    output dbg0,
    output dbg1);

	wire [13:0] bus_addr;
	wire [15:0] bus_wrdata, bus_rddata;
    wire        bus_cyc, bus_write, bus_ack;

    assign dbg0 = 0;
    assign dbg1 = 0;

    assign bus_ack = bus_cyc;	// always access spram

	cpu cpu(
		.rst(rst),
		.clk(clk),
		.bus_addr(bus_addr),
		.bus_wrdata(bus_wrdata),
		.bus_rddata(bus_rddata),
		.bus_cyc(bus_cyc),
		.bus_write(bus_write),
		.bus_ack(bus_ack));

	sb_spram256ka spram(
		.clk(clk),
		.addr(bus_addr),
		.din(bus_wrdata),
		.wren(bus_write),
		.cs(bus_cyc),
		.dout(bus_rddata));

endmodule
