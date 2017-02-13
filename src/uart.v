// Simple NOT gate module

module uart(Clk, rx, data);
	input Clk;
	input rx;
	output reg [7:0] data;
	
	parameter IDLE = 2'b00;
	parameter RECIEVE = 2'b01;
	parameter SAMPLE = 52;
	parameter DATA_BITS = 8;
	parameter STOP_BITS = 2;

	reg [6:0] counter;
	reg [3:0] index;
	reg [1:0] state;

	initial
	begin
		counter <= 0;
		state <= IDLE;
		index <= 0;	
	end

	always @(posedge Clk)
	begin
		case (state)
		IDLE:
		begin
			if (counter == SAMPLE)
			begin
				counter <= 0;
				if (rx == 1'b0)
					state <= RECIEVE;	
			end				
			else
				counter <= counter + 1;
		end

		RECIEVE:
		begin
			if (counter == SAMPLE && index < DATA_BITS)
			begin
				counter <= 0;
				data[index] <= rx;
				index <= index + 1;
			end
			else if (counter == SAMPLE && index >= DATA_BITS && index < DATA_BITS + STOP_BITS)
			begin
				index <= index + 1;
				counter <= 0;
			end
			else if (counter == SAMPLE && index == DATA_BITS + STOP_BITS)
			begin
				index <= 0;
				state <= IDLE;
				counter <= 0;
			end
			else
			begin
				counter <= counter + 1;
			end
		end
		endcase
	end
endmodule
