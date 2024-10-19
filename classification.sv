module classification(
    input logic clk,
    input logic [3:0] red,
    input logic [3:0] green,
    input logic [3:0] blue,
	 input wire HREF,
    output logic redDetected,
	 output logic [1:0] direction
);

reg [3:0] Threshold = 4'b0101; // Threshold value (adjust as needed)
wire [3:0] filter=4'b0111;
integer red_count_left = 0;
integer red_count_center = 0;
integer red_count_right = 0;
integer pixel_count = 0;


always_ff @(posedge clk) begin
	
	if (HREF) begin
		
		pixel_count <= pixel_count + 1;

		// Red detection
		if (green < filter && blue < filter && red > Threshold) begin
			
			//
			redDetected <= 1'b1;
			
			//
			if(pixel_count < 100) begin
				
				red_count_left = red_count_left + 1;
			
			end
			else if (pixel_count >= 100 && pixel_count < 295) begin
			
				red_count_center = red_count_center + 1;
			
			end
			else if (pixel_count >= 295 && pixel_count <= 320) begin
			
				red_count_right = red_count_right +1;
				
			end
			
			//
			if ( red_count_right > (red_count_left)) begin
				
				direction <= 2'b01;
			
			end
			else if (red_count_center > red_count_right && red_count_center > red_count_left) begin
				
				direction <= 2'b10;
				
			end 
			else if (red_count_left > (red_count_right)) begin
			
				direction <= 2'b11;
			
			end
//			else begin
//				
//				direction <= 2'b10;
//				
//			end
			
			//
			if (pixel_count >= 320) begin
			
				red_count_center <= 0;
				red_count_right <= 0;
				red_count_left <= 0;
			
			end
			
		end 
		else begin
			
			//
			redDetected <= 1'b0;
			red_count_center <= 0;
			red_count_right <= 0;
			red_count_left <= 0;
		
		end
	end
	else begin
		
		pixel_count <= 0;
		red_count_center <= 0;
		red_count_right <= 0;
		red_count_left <= 0;
		
	end
		
	
end



endmodule