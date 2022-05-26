clear -all;
analyze -sv12 {congruence.sv};
elaborate -disable_auto_bbox;
clock -infer;
reset -none;
# Word-level engines must be enabled or properties will lead to
# inconsistent results.
prove -bg -all -engine_mode {WHp WHt WHps WB WB1 WB2 WB3 WI WAM};
