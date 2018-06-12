// `define IR 15

module cpu #( ADDR_WIDTH = 14, MEM_WIDTH = 16, REG_WIDTH = 16 ) (
    // Misc
    input         rst,
    input         clk,

    // bus master
    output [ADDR_WIDTH-1:0] bus_addr,
    output [MEM_WIDTH-1:0] bus_wrdata,
    input  [MEM_WIDTH-1:0] bus_rddata,
    output        bus_cyc,
    output        bus_write,
    input         bus_ack);

	// 
	reg [31:0] registers [0:REG_WIDTH-1] = '{ default:32'hAAAAAAAA };
	reg [3:0] state;

	reg [REG_WIDTH-1:0] instruction;

	// typedef
	enum reg [1:0] { FETCH, DECODE, LOAD, STORE } decode_state;

	localparam ACCUM = 0;
	localparam INDEX = 14;
	localparam PCNTR = 15;

	typedef logic [ADDR_WIDTH-1:0] ADDR;
	typedef logic [MEM_WIDTH-1:0] MEM;

	always @(*) begin
		case (decode_state)
			FETCH: begin
				bus_write = 0;
				bus_addr = ADDR'(registers[PCNTR]);
				bus_cyc = 1;
			end
			DECODE: begin
				bus_write = 0;
				bus_addr = 'X;
				bus_cyc = 0;
			end
			LOAD: begin
				bus_write = 0;
				bus_addr = ADDR'(registers[INDEX]);
				bus_cyc = 1;
			end
			STORE: begin
				bus_write = 1;
				bus_addr = ADDR'(registers[INDEX]);
				bus_wrdata = MEM'(registers[ACCUM]);
				bus_cyc = 1;
			end
		endcase
	end

	always @(posedge clk) begin
		if (rst) begin
			registers[PCNTR] <= 0;
		end else begin

			case (decode_state)
				FETCH: begin
        			$display("[%0t] fetch %04X...", $time, bus_rddata);
					if (bus_ack) begin
						instruction <= bus_rddata;
					end
					decode_state <= DECODE;
					registers[PCNTR] <= registers[PCNTR] + 1;
				end
				DECODE: begin
        			$display("[%0t] decode...", $time);
					decode_state <= LOAD;
				end
				LOAD: begin
					decode_state <= STORE;
				end
				STORE: begin
					decode_state <= FETCH;
				end
			endcase

		end
	end

endmodule
