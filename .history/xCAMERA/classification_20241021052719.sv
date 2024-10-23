module classification(
    input logic clk,
    input logic [3:0] red,
    input logic [3:0] green,
    input logic [3:0] blue,
	input wire HREF,
	input wire fast,
	input logic is_orange,
    output logic orangeDetected,
	output logic [2:0] direction
);

integer orange_count_left = 0;
integer orange_count_center = 0;
integer orange_count_right = 0;
integer pixel_count = 0;


always_ff @(posedge clk) begin
	
	if (HREF) begin
		
		pixel_count <= pixel_count + 1;

		// Orange detection
		if (is_orange) begin
			
			//
			orangeDetected <= 1'b1;
			
			//
			if(pixel_count < 100) begin
				
				orange_count_left = orange_count_left + 1;
			
			end
			else if (pixel_count >= 100 && pixel_count < 295) begin
			
				orange_count_center = orange_count_center + 1;
			
			end
			else if (pixel_count >= 295 && pixel_count <= 320) begin
			
				orange_count_right = orange_count_right +1;
				
			end
			
			//
			if ( orange_count_right > (orange_count_left)) begin
				
				direction <= 3'b010;
			
			end
			else if (orange_count_center > orange_count_right && orange_count_center > orange_count_left) begin
				
				if (fast) begin
					direction <= 3'b011;
				end else begin
					direction <= 3'b100;
				end
				
			end 
			else if (orange_count_left > (orange_count_right)) begin
			
				direction <= 3'b001;
			
			end
			
			//
			if (pixel_count >= 320) begin
			
				orange_count_center <= 0;
				orange_count_right <= 0;
				orange_count_left <= 0;
			
			end
			
		end 
		else begin
			
			//
			orangeDetected <= 1'b0;
			orange_count_center <= 0;
			orange_count_right <= 0;
			orange_count_left <= 0;
		
		end
	end
	else begin
		
		pixel_count <= 0;
		orange_count_center <= 0;
		orange_count_right <= 0;
		orange_count_left <= 0;
		
	end
		
	
end



endmodule