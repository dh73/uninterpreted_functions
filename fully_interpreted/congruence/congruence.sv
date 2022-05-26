`default_nettype none
module congruence(input wire clk);
   logic [3:0] a, b;
   var logic [7:0] uf [0:15];

   congruence_prop: assert property(@(posedge clk)
				    a == b |-> uf[a] == uf[b]);
   congruence_wit: cover property(@(posedge clk)
				    a == b ##0 uf[a] == uf[b]);
endmodule // congruence
`default_nettype wire
