module hydra_pll(PACKAGEPIN,
                 PLLOUTCORE,
                 PLLOUTGLOBAL,
                 DYNAMICDELAY,
                 RESET,
                 LOCK);

input PACKAGEPIN;
input [7:0] DYNAMICDELAY;
input RESET;    /* To initialize the simulation properly, the RESET signal (Active Low) must be asserted at the beginning of the simulation */ 
output PLLOUTCORE;
output PLLOUTGLOBAL;
output LOCK;

SB_PLL40_PAD hydra_pll_inst(.PACKAGEPIN(PACKAGEPIN),
                            .PLLOUTCORE(PLLOUTCORE),
                            .PLLOUTGLOBAL(PLLOUTGLOBAL),
                            .EXTFEEDBACK(),
                            .DYNAMICDELAY(DYNAMICDELAY),
                            .RESETB(RESET),
                            .BYPASS(1'b0),
                            .LATCHINPUTVALUE(),
                            .LOCK(LOCK),
                            .SDI(),
                            .SDO(),
                            .SCLK());

//\\ Fin=10, Fout=100;
defparam hydra_pll_inst.DIVR = 4'b0000;
defparam hydra_pll_inst.DIVF = 7'b0001001;
defparam hydra_pll_inst.DIVQ = 3'b011;
defparam hydra_pll_inst.FILTER_RANGE = 3'b001;
defparam hydra_pll_inst.FEEDBACK_PATH = "DELAY";
defparam hydra_pll_inst.DELAY_ADJUSTMENT_MODE_FEEDBACK = "DYNAMIC";
defparam hydra_pll_inst.FDA_FEEDBACK = 4'b0000;
defparam hydra_pll_inst.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
defparam hydra_pll_inst.FDA_RELATIVE = 4'b0000;
defparam hydra_pll_inst.SHIFTREG_DIV_MODE = 2'b00;
defparam hydra_pll_inst.PLLOUT_SELECT = "GENCLK";
defparam hydra_pll_inst.ENABLE_ICEGATE = 1'b0;

endmodule
