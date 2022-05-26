clear -all;
analyze -sv12 {partial_uf_alu.sv};
elaborate -disable_auto_bbox;
clock -infer;
reset -expression {~rstn};
# Word-level engines must be enabled or properties will lead to
# inconsistent results.
prove -bg -all -engine_mode {WHp WHt WHps WB WB1 WB2 WB3 WI WAM};

