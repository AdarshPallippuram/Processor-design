
//***************************************************************
//-----------------------------------------------------------------------------ALU HARDWARE MODULE-------------------------------------------------------------------------------------------
//***************************************************************

//Control Signals :clk
//	          :ps_alu_en
//                :ps_alu_log
//                :ps_alu_hc     (bits 21-20) 
//                :ps_alu_sc     (bits 19-18-17)
//                :ps_alu_hc[1]   21st bit of opcode 
//                :ps_alu_sc[0]    17th bit of opcode
//                :alu_sat




//Flags:alu_zero(Zero)
//     :alu_neg(Negative)
//     :alu_carry(Carry)
//     :alu_of(Overflow)



module alu #(parameter DATA_WIDTH=16)(clk, xb_cu_rx, xb_cu_ry, ps_alu_en, ps_alu_log, ps_alu_hc, ps_alu_sc, alu_xb_rn, alu_sat, alu_zero, alu_neg, alu_carry, alu_of);

input clk, xb_cu_rx, xb_cu_ry ,ps_alu_en, ps_alu_log, ps_alu_hc, ps_alu_sc, alu_sat;      
wire clk;                                                                                        
wire [(DATA_WIDTH-1):0]xb_cu_rx;
wire [(DATA_WIDTH-1):0]xb_cu_ry;
wire ps_alu_en, ps_alu_log;
wire [1:0]ps_alu_hc;
wire [2:0]ps_alu_sc;
wire alu_sat;

output alu_xb_rn, alu_zero, alu_neg, alu_carry, alu_of;
reg [(DATA_WIDTH-1):0]alu_xb_rn;
reg alu_zero,alu_neg,alu_carry,alu_of;

reg  [(DATA_WIDTH):0]value;
reg  [(DATA_WIDTH-1):0]x;
reg  [(DATA_WIDTH-1):0]y;
reg alu_enabl;
reg arith_logic;
reg [1:0]high_class;
reg [2:0]sub_class;


always@(posedge clk)
begin 
          alu_enabl<= ps_alu_en;
end 

always@(posedge clk)
begin
         if(ps_alu_en)
                begin
                      arith_logic<= ps_alu_log;
                      high_class<= ps_alu_hc;
                      sub_class<= ps_alu_sc;
                end 

end  



always@(posedge clk)
begin
		x<= ps_alu_en? xb_cu_rx:x;
		y<= (ps_alu_en&~ps_alu_hc[1])? xb_cu_ry:y;

end


always@(*)
begin

          if(arith_logic) 
             begin 
                                      
                      case(high_class)
 
                          2'b00: begin
                                  
                                     case(sub_class) 
                                       
                                        3'b000:  //Rx AND Ry
			                          begin
				                   
				                      value=x&y;
                                                      alu_xb_rn= value;
                                                      alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                      alu_carry =0;
                                                      alu_of=0;
			                           end

			                3'b001:	//Rx OR Ry
			                          begin
				                     
				                      value=x|y;
                                                      alu_xb_rn= value;
                                                      alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                      alu_carry =0;
                                                      alu_of=0;
			                          end

			                3'b010:	//Rx XOR Ry
			                          begin
                                                     
				                      value=x^y;
                                                      alu_xb_rn= value;
                                                      alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
			                              alu_carry =0;
                                                      alu_of=0;
                                                 end
                                     endcase 
                                   end 
 
                            2'b10:   begin 
 
                                         case(sub_class)
                
                                         3'b000:  // REG_AND RX
                                                  begin 
                                                      
                                                      value= &x;
                                                      alu_xb_rn= value;
                                                      alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                      alu_carry =0;
                                                      alu_of=0;
                                                   end 

                                          3'b001:  // REG_OR RX
                                                  begin 
                                                     
                                                      value= |x;
                                                      alu_xb_rn= value;
                                                      alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                      alu_carry =0;
                                                      alu_of=0;
                                                   end 
                                          endcase 
 
                                      end 

                              2'b11:   begin 
 
                                          case(sub_class)

                                             3'b000:  // NOT Rx
			                               begin				                           
				                          value=~x;
                                                          alu_xb_rn= value;
                                                          alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                          alu_carry =0;
                                                          alu_of=0;
			                               end
                                          endcase 
			                end 
                          endcase 
                      end


               else

               begin 
                   case(high_class)
			2'b00:	
			        begin
                                    case(sub_class)
                                          3'b000:                     //x+y 
                                                   begin
						   value=x+ (y^{16{sub_class[0]}}) + sub_class[0];
						   alu_xb_rn=value;
                                                   alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                   alu_carry= (value[DATA_WIDTH]==1);
                                                   alu_of=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                           end

			                  3'b001:	              //x-y
			                           begin
				                   value=x+ (y^{16{sub_class[0]}}) + sub_class[0];
						   alu_xb_rn=value;
                                                   alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                   alu_carry= (value[DATA_WIDTH]==1);
                                                   alu_of=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                           end
			
			                  3'b010: 	             //x+y+CI 
			                           begin 
				                   value=x+ (y^{16{sub_class[0]}}) + sub_class[0]+ alu_carry ;
						   alu_xb_rn=value;
                                                   alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                   alu_carry= (value[DATA_WIDTH]==1);
                                                   alu_of=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                           end

			                 3'b011: 	            //x-y+CI-1
			                           begin
				                   value=x+ (y^{16{sub_class[0]}}) + sub_class[0]+ alu_carry - sub_class[0] ;
						   alu_xb_rn=value;
                                                   alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                   alu_carry= (value[DATA_WIDTH]==1);
                                                   alu_of=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                           end

			                3'b101:	   begin 
                                                                    //comp(rx,ry) 
				                   if(x==y)
					             alu_zero=1; 
				                   else
					             alu_zero=0;

                                                   alu_carry =0;
                                                   alu_of =0;
                                                   if(x<y)
                                                      alu_neg = 1'b1;
                                                   else
                                                       alu_neg = 1'b0;

                                                   end 

                                    endcase 
			         end

                      2'b01:  begin
                                
                                case(sub_class)

                                   3'b001: begin                                 //min(rx,ry)
				           value=x+(y^{16{sub_class[0]}})+ sub_class[0];	
				                begin
					           if(value[DATA_WIDTH-1]==1) begin
						         alu_xb_rn=x;
                                                         alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                         alu_carry =0; 
                                                         alu_of=0;
                                                         end 
					           else
                                                         begin
						        alu_xb_rn=y;
                                                        alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                        alu_carry=0;
                                                        alu_of=0;
                                                          end 
				                end
			                   end

                                   3'b011: begin                               //max(rx,ry)                                            
				           value=x+(y^{16{sub_class[0]}})+ sub_class[0];	
				                begin
					             if(value[DATA_WIDTH-1]==1) begin
						         alu_xb_rn=y;
                                                         alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                         alu_carry=0;
                                                         alu_of=0;           end 
					             else
                                                          begin 
						         alu_xb_rn=x;
                                                         alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                         alu_carry=0;
                                                         alu_of=0; end 
				                end
			                   end
                                 endcase 
                              end 


                    2'b10:  begin
                                 
                              case(sub_class) 
                        
                                  3'b001:  begin                                // Rn= -Rx 
				           value=(x^{16{sub_class[0]}})+ sub_class[0];
					   alu_xb_rn=value;
                                           alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                           alu_carry= (value[DATA_WIDTH]==1);
                                           alu_of=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
			                   end
                              endcase 
                            end 


		    2'b11:	                         //Rn = ABS Rx
                             begin
                                    
                                case(sub_class)
                  
                                  3'b001:  begin 
				           if(x[DATA_WIDTH-1]==1) 
				                   begin
					              value=(x^{16{sub_class[0]}})+ sub_class[0];
						      alu_xb_rn=value;
                                                      alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                      alu_carry=0;
                                                      alu_of=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
					           end
				           else
				                   begin
					             value=x;
						     alu_xb_rn=value;
                                                     alu_neg= (alu_xb_rn[DATA_WIDTH-1]==1);
                                                     alu_carry=0;
                                                     alu_of=(value[DATA_WIDTH-2]^value[DATA_WIDTH-1]==1);
				                   end
			                   end
                                 endcase 
                             end 




 endcase 
 end  
end

always@(*)
begin

	begin
		                                                     //Zero Flag
			
		       alu_zero= (alu_xb_rn==16'h0000);
	end


	


                                                                   //Saturation 
        begin
			

                      if(alu_sat)   begin

                                  if(alu_of) 
                                               begin

 				                       if(value[DATA_WIDTH-1]==1)
					                        alu_xb_rn=32'h7fff;
				                       else
					                        alu_xb_rn=32'h8000;

                                                end 
                                    end 
			
      end


end 	

endmodule
		

	
/*
module testalbench #(parameter DATA_WIDTH=16)();
reg  clk;
reg  [DATA_WIDTH-1:0] xb_cu_rx;
reg  [DATA_WIDTH-1:0] xb_cu_ry;
reg ps_alu_en ;
reg ps_alu_log;
reg [1:0]ps_alu_hc;
reg [2:0]ps_alu_sc;
wire alu_zero;
wire alu_neg;
wire alu_carry;
wire alu_of;
wire [(DATA_WIDTH):0]value;
wire  [(DATA_WIDTH-1):0]x;
wire [(DATA_WIDTH-1):0]y;
wire alu_enabl;
wire arith_logic;
wire [1:0]high_class;
wire [2:0]sub_class;

wire signed [DATA_WIDTH-1:0]alu_xb_rn;
reg  alu_sat;

test_alu ta(clk, xb_cu_rx, xb_cu_ry, ps_alu_en, ps_alu_log, ps_alu_hc, ps_alu_sc, alu_xb_rn, alu_sat, alu_zero, alu_neg, alu_carry, alu_of);



initial begin
clk=1;
forever begin
#5 clk=~clk;
end
end 

initial
begin
 
	ps_alu_en=0;
               
       #21 ps_alu_en = 1;
		 
//$urandom_range(1,0);                                                          

end 


initial
begin
 
	alu_sat=0;
	#21
                forever begin
                        
                   #10 alu_sat =$urandom_range(1,0);                                                          
                        end

end 

initial
begin
 
	ps_alu_log =1;
              
               #21 ps_alu_log = 0;  
       #21 ps_alu_log = 1;                                       
                      
end



 

initial
begin
        #21
	ps_alu_hc=2'b10;

                forever begin
                        
                   #10 ps_alu_hc = 2'b11;
                   #10 ps_alu_hc = 2'b00;
                   #10 ps_alu_hc = 2'b00;
                   #10 ps_alu_hc = 2'b00;
                   #10 ps_alu_hc = 2'b00;
                   #10 ps_alu_hc = 2'b00;
                                                         
                        end

end 

initial
begin
          #21
	ps_alu_sc=3'b001;
                forever begin
                        
                   #10 ps_alu_sc = 3'b001;
                   #10 ps_alu_sc = 3'b101;
                   #10 ps_alu_sc = 3'b001;
                   #10 ps_alu_sc = 3'b010;
                   #10 ps_alu_sc = 3'b010;
                   #10 ps_alu_sc= 3'b000;
                                                         
                        end

end 


initial
begin
	 #21
      xb_cu_rx=16'ha001;
               forever begin 
            #10 xb_cu_rx= 16'hb102;
            #10 xb_cu_rx= 16'h0005;
            #10 xb_cu_rx= 16'h0004;
            #10 xb_cu_rx= 16'h0005;
            #10 xb_cu_rx= 16'h0006;
            #10 xb_cu_rx= 16'h0007;
            #10 xb_cu_rx= 16'h0008;
            #10 xb_cu_rx= 16'h0009;
                      end                                                                                   //$urandom_range(0,600); end 
end


initial
begin
	 #21
      xb_cu_ry= 16'hc039;
             forever begin 
            #10 xb_cu_ry=  16'h0002;
            #10 xb_cu_ry=  16'h0073;
            #10 xb_cu_ry=  16'h0001;
            #10 xb_cu_ry=  16'h0d03;
            #10 xb_cu_ry=  16'h00e4;
            #10 xb_cu_ry=  16'h0d07;
            #10 xb_cu_ry=  16'h0f08;
            #10 xb_cu_ry=  16'h0006;                                                                         //$urandom_range(0,600); end 
                    end
end


endmodule
*/