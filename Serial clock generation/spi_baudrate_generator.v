
module spi_baud_generator(input pclk,preset_n,spiswai_i,cpol_i,cpha_i,ss_i,
                          input [1:0] spi_mode_i,input [2:0] sppr_i,spr_i,output reg sclk_o,
						  miso_receive_sck_o,miso_receive_sck0_o,mosi_send_sck_o,mosi_send_sck0_o,
						  output [11:0] baudratedivisor_o);
		
		reg [11:0] count_n;
		wire pre_clk;
		assign baudratedivisor_o=((sppr_i+1)*(2**(spr_i+1)));
		assign pre_clk=(cpol_i)?1'b1:1'b0;
		
		always@(posedge pclk or negedge preset_n)
		 begin
		  if(!preset_n)
		   begin
		    sclk_o<=pre_clk;
			count_n<=12'b0;
		   end
		  else if((!ss_i && !spiswai_i && (spi_mode_i==2'b00 || spi_mode_i==2'b01)))
		   begin
		    if((count_n==baudratedivisor_o/2-1'b1))
			 begin
			  sclk_o<=~sclk_o;
			  count_n<=12'b0;
			 end
			 
			else
			 begin
			  sclk_o<=sclk_o;
			  count_n<=count_n+1'b1;
			 end
		   end
		  else
		   begin
		    sclk_o<=pre_clk;
			count_n<=12'b0;
		   end
		 end
		
		//miso flag generation
		always@(posedge pclk or negedge preset_n)
		 begin
		  if(!preset_n)
		   begin
		    miso_receive_sck0_o<=0;//neg edge
			miso_receive_sck_o<=0;//pos edge
		   end
		  else
		   begin
		   miso_receive_sck0_o<=0;
			miso_receive_sck_o<=0;
		    if((!cpol_i && cpha_i) || (cpol_i && !cpha_i))//neg edge sampling
			 begin
			  if(sclk_o)
			   begin
			    if(count_n==baudratedivisor_o/2-1)
				 miso_receive_sck0_o<=1'b1;
				else
				 miso_receive_sck0_o<=1'b0;
			   end
              else
			   miso_receive_sck0_o<=1'b0;
			 end
			else if((!cpol_i && !cpha_i) || (cpol_i && cpha_i))//posedge smapling
			 begin
			  if(!sclk_o)
			   begin
			    if(count_n==baudratedivisor_o/2-1'b1)
				 miso_receive_sck_o<=1'b1;
			    else
				 miso_receive_sck_o<=1'b0;
			   end
			  else
			   miso_receive_sck_o<=0;
			 end
		   end
		 end
		
		//mosi flags generation
		always@(posedge pclk or negedge preset_n)
		 begin
		  if(!preset_n)
		   begin
		    mosi_send_sck0_o<=1'b0;
			mosi_send_sck_o<=1'b0;
		   end
		  else
		   begin
		   mosi_send_sck0_o<=1'b0;
			mosi_send_sck_o<=1'b0;
		    if((!cpol_i && cpha_i) || (cpol_i && !cpha_i))//negedge sampling
			 begin
			  if(sclk_o)
			   begin
			    if(count_n==baudratedivisor_o/2-2'b10)
				 mosi_send_sck0_o<=1'b1;
				else
				 mosi_send_sck0_o<=1'b0;
			   end
              else
			   mosi_send_sck0_o<=1'b0;
			 end
			else if((!cpol_i && !cpha_i) || (cpol_i && cpha_i))
			 begin
			  if(!sclk_o)
			   begin
			    if(count_n==baudratedivisor_o/2-2'b10)
				 mosi_send_sck_o<=1'b1;
				else
				 mosi_send_sck_o<=1'b0;
			   end
			  else
			   mosi_send_sck_o<=0;
			 end
		   end
		 end
			 
			   
endmodule	 
