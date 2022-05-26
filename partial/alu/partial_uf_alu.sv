`default_nettype none
`ifndef _PARTIAL_UF_ALU_
 `define _PARTIAL_UF_ALU_
package partial_uf_alu_pkg;
   typedef enum logic [1:0] {ADD, SUB, AND, OR} opcodes_t;
   localparam WORD_SIZE = 32;
   typedef logic [WORD_SIZE-1:0] u32;
   localparam NUM_SYMBOLS = 4;
endpackage // partial_uf_alu_pkg
`endif

module partial_uf_alu import partial_uf_alu_pkg::*;
   (input wire clk,
    input wire rstn,
    input wire opcodes_t op,
    input wire u32 in_data,
    input wire u32 in_datb,
    output     u32 out_res);

   /* Generate two symbolic variables to help reduce
    * the explosion in the array size */
   var u32 exist_arga;
   var u32 exist_argb;
   asm_e_arga: assume property(@(posedge clk) disable iff(!rstn)
			       1'b1 ##1 $stable(exist_arga));
   asm_e_argb: assume property(@(posedge clk) disable iff(!rstn)
			       1'b1 ##1 $stable(exist_argb));
   wire        exists_value_dataa =  in_data == exist_arga;
   wire        exists_value_datab =  in_datb == exist_argb;

   // Uninterpreted function
   var u32 uf [0:$clog2(NUM_SYMBOLS)+1];

   // some easy congruence definitions
   let dummy_max(x, y) = ((x > y) ? x : y);
   congruence_0: assume property(@(posedge clk) disable iff(!rstn)
				 exist_arga & exist_argb |-> uf[{in_data[0], in_datb[0]}] > dummy_max(in_data, in_datb));

   always_ff @(posedge clk) begin
      if(!rstn) out_res <= '0;
      else begin
	 if(op == ADD & in_data == '0)
	   out_res <= in_datb;
	 else begin
	    if(op == ADD & exists_value_dataa & exists_value_datab)
	      out_res <= uf[{in_data[0], in_datb[0]}];
	 end
      end
   end // always_ff @ (posedge clk)

   uf_when_onearg_is_null: assert property(@(posedge clk) disable iff(!rstn)
					   op == ADD && in_data == '0 |=> out_res == $past(in_datb));

   cov_uf_null_arg: cover property(@(posedge clk) disable iff(!rstn)
				   op == ADD && in_data == '0 ##1 out_res == $past(in_datb));

   let nonzero_val(arg) = (arg != '0);
   cov_any_other_val: cover property(@(posedge clk) disable iff(!rstn) ##1
				     nonzero_val(in_data) & nonzero_val(in_datb) & op == ADD &
				     exists_value_dataa & exists_value_datab &
				     uf[in_data[1:0]] != uf[in_datb[1:0]] ##1 1'b1);
endmodule // partial_uf_alu
`default_nettype wire
