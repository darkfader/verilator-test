// `define IR 15

module cpu #( parameter ADDR_WIDTH = 14 ) (
    // Misc
    input         rst,
    input         clk,

    // bus master
    output [ADDR_WIDTH-1:0] bus_addr,
    output [15:0] bus_wrdata,
    input  [15:0] bus_rddata,
    output        bus_cyc,
    output        bus_write,
    input         bus_ack);

	// 
	reg [31:0] registers [0:15] = '{ default:32'3 };
	reg [3:0] state;

	reg [15:0] instruction;

	// typedef
	enum reg [1:0] { FETCH, DECODE, LOAD, STORE } decode_state;

	localparam MR = 14;
	localparam IR = 15;

	typedef logic [ADDR_WIDTH-1:0] HALF_WORD;

	always @(*) begin
		case (decode_state)
			FETCH: begin
				bus_write = 0;
				bus_addr = HALF_WORD'(registers[IR]);
				bus_cyc = 1;
			end
			DECODE: begin
				bus_write = 0;
				bus_addr = 'X;
				bus_cyc = 0;
			end
			LOAD: begin
				bus_write = 0;
				bus_addr = HALF_WORD'(registers[MR]);
				bus_cyc = 1;
			end
			STORE: begin
				bus_write = 1;
				bus_addr = HALF_WORD'(registers[MR]);
				bus_cyc = 1;
			end
		endcase
	end

	always @(posedge clk) begin
		if (rst) begin
			registers[IR] <= 0;
		end else begin

			case (decode_state)
				FETCH: begin
        			$display("[%0t] fetch %04X...", $time, bus_rddata);
					if (bus_ack) begin
						instruction <= bus_rddata;
					end
					decode_state <= DECODE;
					registers[IR] <= registers[IR] + 1;
				end
				DECODE: begin
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
