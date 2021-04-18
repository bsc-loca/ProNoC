`timescale     1ns/1ns

module testbench;

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

    `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"
    `include "trace_files.v"
    

// Ports

    reg  reset;
    reg  clk;
   
    reg   [WRAP_REQ_W-1:0]   wrapreq [NUM_OF_RNs-1 : 0];
    reg   [NUM_OF_RNs-1 : 0] wrapreqvalid;
    wire  [NUM_OF_RNs-1 : 0] tim_wrap_strobereq;    


	wire [WRAP_REQ_W*NUM_OF_RNs-1 : 0] wrapreq_all;


//file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/wr_rd_rd_clnu/trace/trace.bin", "rb");
task automatic pck_inject_rd_trace;
    input integer in;
    input integer file_pt;
	input integer read_trace_num;
	reg [63: 0] trace;
	reg [31: 0] trace_line;
        reg [31: 0] wait_counter;
	begin
	if (file_pt == 0) begin
   	    $display("data_file handle was NULL");
    	    $finish;
   	 end
    
    $display("***************start feeding traces to packet injector %d************",in);
    
    wrapreq[in]={WRAP_REQ_W{1'b0}};
    wrapreqvalid[in]=1'b0;
    trace_line=0;
    wait_counter=0; 
	while (!$feof(file_pt) && trace_line< read_trace_num)begin         
    	if(!$feof(file_pt)) begin     
       		if($fread(trace, file_pt)==-1) $display("ERROR: fread failed");
            trace_line=trace_line+1;
           // $display("RN[%d] trace_line=%d",in,trace_line);
      		if(!$feof(file_pt)) begin //the last data read from the file is invalid?        
               //	$display ("%t:RN[%d] read trace num %d: %h\n",$time,in,trace_line,trace);
                wrapreq[in]= trace & 64'h000000ffffffffff;
              	wrapreqvalid[in]=1'b1;
		#1 if(tim_wrap_strobereq[in]==1'b0) begin 
		       	#1 while(tim_wrap_strobereq[in]==1'b0 ) begin 
				#1 @(posedge clk); 
				 wait_counter=wait_counter+1;
				if(wait_counter>=100000) begin 
						$display ("%t:RN[%d] is hanged at line %d for %d clk cycle\n",$time,in,trace_line,wait_counter);
						$stop;
				end
			end
			$display ("%t:RN[%d] read trace num %d: %h\n",$time,in,trace_line,wrapreq[in]);
		end else begin 
		       	#1 @(posedge clk);
				$display ("%t:RN[%d] read trace num %d: %h\n",$time,in,trace_line,wrapreq[in]);
				wait_counter=0;
		   	end
		end
        end       
    end
    wrapreqvalid[in]=1'b0;
    $display("End of trace file %d at trace_line=%d ",in,trace_line);
    $fclose(file_pt);
    #20100; 
    injct_done[in]=1'b1;
    $display("***************End of feeding traces to packet injector %d************",in);
    end
endtask





    genvar i;
    generate 
    for(i=0;i<NUM_OF_RNs;i=i+1)begin: rn
        assign wrapreq_all [WRAP_REQ_W*(i+1)-1 : WRAP_REQ_W*i] =wrapreq[i];	
    end 
    endgenerate 
    
    
    

// top module instance
    top_chi_noc #(
        .VERBOSITY(VERBOSITY),
        .B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .ROUTE_NAME(ROUTE_NAME),
        .SYS_CACHE_EN(SYS_CACHE_EN),
        .NUM_OF_RNs(NUM_OF_RNs),
        .NUM_OF_HNs(NUM_OF_HNs),
        .NUM_OF_SNs(NUM_OF_SNs)
    )
    top_mesh
    (
        .reset(reset),
        .clk(clk),
        
        .wrapreq_all(wrapreq_all),
        .wrapreqvalid(wrapreqvalid),
        .tim_wrap_strobereq(tim_wrap_strobereq)
        
        
    );

initial begin 
    clk = 1'b0;
    forever clk = #10 ~clk;
end 


	reg [31 : 0] deactive_counter [NUM_OF_RNs-1 : 0];
	reg [31 : 0] trace_line  [NUM_OF_RNs-1 : 0];
	reg [63: 0] trace  [NUM_OF_RNs-1 : 0];
	reg [31 : 0] clk_counter;

	always @ (posedge clk or posedge reset)begin 
		if(reset) clk_counter<=0;
		else clk_counter <= clk_counter +1'b1;
	end


   genvar j;
    generate 
    for(j=0;j<NUM_OF_RNs;j=j+1) begin : jlp 
  	localparam TRACE_FILE=get_trace_file(j);
   
        initial begin
          //  injct_done[j]=1'b0;
          // wrapreqvalid[j]=1'b0;
	  //  wrapreq [j]=1'b0;	    
           
	    if(TRACE_FILE!="OFF")  file[j] = $fopen(TRACE_FILE,"rb");	
	    #1
	    if (file[j] == 0) begin
	   	    $display("data_file handle was NULL");
	    	    $finish;

            end
            
       
             
          
            
        end  //initial 
//&& (trace_line[j] & 'h7FF)==0

	always @ (posedge clk) begin 
		#1 if(tim_wrap_strobereq[j]==1'b1 && wrapreqvalid[j]==1'b1 && (trace_line[j] & 'hFFF)==0 )$display ("%d:RN[%d] read trace num %d: %h\n",clk_counter-1,j,trace_line[j],wrapreq[j]);
	end



	always @ (posedge clk) begin 
		if(reset)begin 
			deactive_counter[j]=0;
			trace_line[j]=0;
			injct_done[j]=1'b0;
			wrapreqvalid[j]=1'b0;
	    	        wrapreq [j]=1'b0;	    
		end else begin
		
			if(injct_done[j] == 1'b0 && clk_counter>= 2000)begin 
							
				if(tim_wrap_strobereq[j]==1'b0)begin  
			 		deactive_counter[j]<=deactive_counter[j]+1;
					if(deactive_counter[j]>=100000) begin 
						$display ("%t:RN[%d] is hanged at line %d for %d clk cycle\n",$time,j,trace_line[j],deactive_counter[j]);
						$stop;
					end

				end 
				else begin 
					 deactive_counter[j]<=0;
					
						if(TRACE_FILE=="OFF") begin 
							injct_done[j]<=1'b1;  
						end


						else if(!$feof(file[j] ) &&  trace_line[j] < (2*REPEAT_NUM)) begin  
							if($fread(trace[j], file[j],j,1)==-1) $display("ERROR: fread failed");
							wrapreq[j]<= trace[j] & 64'h000000ffffffffff;
			      				wrapreqvalid[j]<=1'b1;
							//$display ("%d:RN[%d] read trace num %d: %h\n",clk_counter,j,trace_line[j],trace[j] & 64'h000000ffffffffff);
							trace_line[j]<=trace_line[j]+1;
							//wait_counter[j]<=1'b1;

						end else begin 
							injct_done[j] <= 1'b1;
							wrapreqvalid[j] <=1'b0;
							if($feof(file[j])) $display("End of trace file %d at trace_line=%d\n",j,trace_line[j]);
							else $display("inject %d Reached max trace num %d\n",j,trace_line[j]);

						end
					
				end//tim_wrap_strobere
	
			end//injct_done		
		end//reset
	end//always



   
 end//for
 endgenerate


 initial begin
        reset=1'b1;
        #100;
        reset=1'b0;
        #100
        while ( &injct_done != 1'b1) #10;  
        #100;
	$display("Simulation is ended successfully!");
        $stop;
    end    




	
     
     
    
   


endmodule



