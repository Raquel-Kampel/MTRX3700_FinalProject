module speed_boost(
    input logic speed,
	output reg fin_speed 
);
	logic c = 0;
	logic x =0;
	logic n_speed = 0; 
	logic m_speed =0;
	always_ff @(posedge speed)begin
		if (x==0)begin
			m_speed=1;
			x=1;
		end
		else if (x==1)begin
			m_speed=0;
			x=0;
		end
	end
	
	
	always_ff @(negedge speed) begin
		if(c==0)begin
			n_speed=1;
			c=1;
		end
		else if (c==1)begin
			n_speed=0;
			c=0;
		end
	end
	
	assign fin_speed=(n_speed||m_speed);

endmodule

