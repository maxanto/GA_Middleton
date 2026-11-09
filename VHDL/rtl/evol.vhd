-- ============================================================================
-- Clean migrated GA source. Descendant generation: crossover selection followed by mutation.
-- Suggested descriptive name (documentation only; NOT applied): offspring_generator
-- Original identifiers are intentionally retained wherever verified.
-- ============================================================================
-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"
-- CREATED		"Mon May 18 13:40:32 2026"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY evol IS 
	GENERIC (
		Npadre : INTEGER := 48;
		Nparam : INTEGER := 16
	);
	PORT (
		clk       :  IN   STD_LOGIC;
		rst       :  IN   STD_LOGIC;
		Hcros     :  IN   STD_LOGIC;
		Hpmut     :  IN   STD_LOGIC;
		P1        :  IN   STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
		P2        :  IN   STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
		individuo :  OUT  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0)
	);
END evol;

ARCHITECTURE bdf_type OF evol IS 

	ATTRIBUTE black_box : BOOLEAN;
	ATTRIBUTE noopt : BOOLEAN;


	-----------------------------
	-- COMPONENTS
	-----------------------------
	COMPONENT cross_binario
		GENERIC (
			Npadre : INTEGER;
			NParam : INTEGER;
			Nprng  : INTEGER);
		PORT(
			p1           : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			p2           : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			prng_A       : IN  STD_LOGIC_VECTOR(Nprng -1 DOWNTO 0);
			prng_r       : IN  STD_LOGIC_VECTOR(Nprng -1 DOWNTO 0);
			prng_SigmaG2 : IN  STD_LOGIC_VECTOR(Nprng -1 DOWNTO 0);
			hijo         : OUT STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT prng_lfsr
		GENERIC (Nprng : INTEGER);
		PORT(
			clk    : IN  STD_LOGIC;
			reset  : IN  STD_LOGIC;
			enable : IN  STD_LOGIC;
			seed   : IN  STD_LOGIC_VECTOR(Nprng-1 DOWNTO 0);
			prng_o : OUT STD_LOGIC_VECTOR(Nprng-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT mux_hijos
		GENERIC (
			Npadre : INTEGER;
			NParam : INTEGER;
			Nprng  : INTEGER);
		PORT(
			h_bin     : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			h_creep   : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			h_shuffle : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			p1        : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			p2        : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			val_prng  : IN  STD_LOGIC_VECTOR(Nprng -1 DOWNTO 0);
			o_sel     : OUT STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT mutacion
		GENERIC (
			ID     : INTEGER;
			Nmut   : INTEGER;
			Nparam : INTEGER;
			Nprng  : INTEGER;
			P      : INTEGER);
		PORT(
			mutate_req : IN  STD_LOGIC;
			gen_in     : IN  STD_LOGIC_VECTOR(Nparam-1 DOWNTO 0);
			prng_i     : IN  STD_LOGIC_VECTOR(Nprng -1 DOWNTO 0);
			gen_out    : OUT STD_LOGIC_VECTOR(Nparam-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT cross_creep
		GENERIC (
			Npadre : INTEGER;
			NParam : INTEGER;
			Nprng  : INTEGER);
		PORT(
			padre        : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			prng_A       : IN  STD_LOGIC_VECTOR(Nprng -1 DOWNTO 0);
			prng_r       : IN  STD_LOGIC_VECTOR(Nprng -1 DOWNTO 0);
			prng_SigmaG2 : IN  STD_LOGIC_VECTOR(Nprng -1 DOWNTO 0);
			hijo         : OUT STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT cross_shuffle
		GENERIC (
			Npadre : INTEGER;
			NParam : INTEGER);
		PORT(
			bit_rand_A     : IN  STD_LOGIC;
			bit_rand_r     : IN  STD_LOGIC;
			bit_rand_Sigma : IN  STD_LOGIC;
			p1             : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			p2             : IN  STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0);
			hijo           : OUT STD_LOGIC_VECTOR(Npadre-1 DOWNTO 0));
	END COMPONENT;

	-----------------------------
	-- SIGNALS
	-----------------------------
	SIGNAL	P1_reg                :  STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL	P2_reg                :  STD_LOGIC_VECTOR(47 DOWNTO 0);

	--SIGNAL	seed_cross_bin        :  STD_LOGIC_VECTOR( 3 DOWNTO 0);
	SIGNAL	prng_cross_bin_A      :  STD_LOGIC_VECTOR( 3 DOWNTO 0);
	SIGNAL	prng_cross_bin_r      :  STD_LOGIC_VECTOR( 3 DOWNTO 0);
	SIGNAL	prng_cross_bin_s      :  STD_LOGIC_VECTOR( 3 DOWNTO 0);
	SIGNAL	hijo_cross_bin        :  STD_LOGIC_VECTOR(47 DOWNTO 0);
	
	-- Independent seeds for Binary Crossover
        SIGNAL seed_cross_bin_A : STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seed_cross_bin_r : STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seed_cross_bin_s : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Independent seeds for Creep Crossover
       SIGNAL seed_cross_creep_A : STD_LOGIC_VECTOR(2 DOWNTO 0);
       SIGNAL seed_cross_creep_r : STD_LOGIC_VECTOR(2 DOWNTO 0);
      SIGNAL seed_cross_creep_s : STD_LOGIC_VECTOR(2 DOWNTO 0);
      
      
	SIGNAL	seed_cross_creep_shuf :  STD_LOGIC_VECTOR( 2 DOWNTO 0);
	SIGNAL	prng_cross_creep_A    :  STD_LOGIC_VECTOR( 2 DOWNTO 0);
	SIGNAL	prng_cross_creep_r    :  STD_LOGIC_VECTOR( 2 DOWNTO 0);
	SIGNAL	prng_cross_creep_s    :  STD_LOGIC_VECTOR( 2 DOWNTO 0);
	SIGNAL	hijo_cross_creep      :  STD_LOGIC_VECTOR(47 DOWNTO 0);
	
	SIGNAL	prng_cross_shuf       :  STD_LOGIC_VECTOR( 2 DOWNTO 0);
	SIGNAL	hijo_cross_shuf       :  STD_LOGIC_VECTOR(47 DOWNTO 0);

	SIGNAL	seed_mux_hijos        :  STD_LOGIC_VECTOR( 6 DOWNTO 0);
	SIGNAL	prng_mux_hijos        :  STD_LOGIC_VECTOR( 6 DOWNTO 0);

	SIGNAL	seed_mutacion         :  STD_LOGIC_VECTOR( 3 DOWNTO 0);
	Signal  seed_mut_A            :   STD_LOGIC_VECTOR( 6 DOWNTO 0);
	Signal  seed_mut_r            :   STD_LOGIC_VECTOR( 6 DOWNTO 0);
	Signal  seed_mut_s            :   STD_LOGIC_VECTOR( 6 DOWNTO 0);
	SIGNAL	prng_mutacion_A       :  STD_LOGIC_VECTOR( 6 DOWNTO 0);
	SIGNAL	prng_mutacion_r       :  STD_LOGIC_VECTOR( 6 DOWNTO 0);
	SIGNAL	prng_mutacion_s       :  STD_LOGIC_VECTOR( 6 DOWNTO 0);

	SIGNAL	gen                   :  STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL	cromosoma             :  STD_LOGIC_VECTOR(47 DOWNTO 0);

	SIGNAL	cormosoma_reg_enable  :  STD_LOGIC;
	SIGNAL	prng_reset            :  STD_LOGIC;

BEGIN 

	-- C2: external reset is active low; prng_lfsr uses active-high reset.
	prng_reset <= not rst;

	----------------------------------------------------------
	-- PARENTS REGISTER
	----------------------------------------------------------

	-- Register parent1 input
	b2v_inst1 : entity work.lpm_dff
		GENERIC MAP(LPM_WIDTH => 48)
		PORT MAP(
			clock => clk,
			data  => P1,
			q     => P1_reg);

	-- Register parent2 input
	b2v_inst11 : entity work.lpm_dff
		GENERIC MAP(LPM_WIDTH => 48)
		PORT MAP(
			clock => clk,
			data  => P2,
			q     => P2_reg);


	----------------------------------------------------------
	-- PRNG for BINARY CROSSOVER
	----------------------------------------------------------


	-- Distinct seeds for Binary Crossover
    b2v_scb_A : entity work.lpm_constant
        GENERIC MAP(LPM_CVALUE => 3, LPM_WIDTH => 4)
        PORT MAP(result => seed_cross_bin_A);

    b2v_scb_R : entity work.lpm_constant
        GENERIC MAP(LPM_CVALUE => 7, LPM_WIDTH => 4)
        PORT MAP(result => seed_cross_bin_r);

    b2v_scb_S : entity work.lpm_constant
        GENERIC MAP(LPM_CVALUE => 11, LPM_WIDTH => 4)
        PORT MAP(result => seed_cross_bin_s);

	-- PRNG for A binary crossover
	b2v_inst4 : prng_lfsr
		GENERIC MAP(Nprng => 4)
		PORT MAP(
			clk    => clk,
			reset  => prng_reset,
			enable => Hcros,
			seed   => seed_cross_bin_A,
			prng_o => prng_cross_bin_A ); -- prng_A

	-- PRNG for r binary crossover
	b2v_inst5 : prng_lfsr
		GENERIC MAP(Nprng => 4)
		PORT MAP(
			clk    => clk,
			reset  => prng_reset,
			enable => Hcros,
			seed   => seed_cross_bin_r,
			prng_o => prng_cross_bin_r ); -- prng_r

	-- PRNG for sigmaG2 binary crossover
	b2v_inst6 : prng_lfsr
		GENERIC MAP(Nprng => 4)
		PORT MAP(
			clk    => clk,
			reset  => prng_reset,
			enable => Hcros,
			seed   => seed_cross_bin_s,
			prng_o => prng_cross_bin_s ); -- prng_sigmaG2


	----------------------------------------------------------
	-- BINARY CROSSOVER
	----------------------------------------------------------

	-- Binary crossover
	b2v_inst : cross_binario
		GENERIC MAP(
			Npadre => 48,
			NParam => 16,
			Nprng  =>  4)
		PORT MAP(
			p1           => P1_reg, -- Registered parent 1
			p2           => P2_reg, -- Registered parent 2
			prng_A       => prng_cross_bin_A , -- prng_A
			prng_r       => prng_cross_bin_r , -- prng_r
			prng_SigmaG2 => prng_cross_bin_s , -- prng_sigmaG2
			hijo 		 => hijo_cross_bin); -- binary crossover offspring


	----------------------------------------------------------
	-- PRNG for CREEP CROSSOVER
	----------------------------------------------------------

	-- Constant seed for creep crossover and shuffle PRNG
	b2v_inst15 : entity work.lpm_constant
		GENERIC MAP(LPM_CVALUE => 2, LPM_WIDTH => 3)
		PORT MAP(result => seed_cross_creep_shuf);
	-- Distinct seeds for Creep Crossover (example with 3-bit width)
    	b2v_scc_A : entity work.lpm_constant
        GENERIC MAP(LPM_CVALUE => 1, LPM_WIDTH => 3)
        PORT MAP(result => seed_cross_creep_A);

    	b2v_scc_R : entity work.lpm_constant
        GENERIC MAP(LPM_CVALUE => 4, LPM_WIDTH => 3)
        PORT MAP(result => seed_cross_creep_r);

   	 b2v_scc_S : entity work.lpm_constant
        GENERIC MAP(LPM_CVALUE => 6, LPM_WIDTH => 3)
        PORT MAP(result => seed_cross_creep_s);
	
	-- PRNG for A creep crossover
	b2v_inst7 : prng_lfsr
		GENERIC MAP(Nprng => 3)
		PORT MAP(
			clk    => clk,
			reset  => prng_reset,
			enable => Hcros,
			seed   => seed_cross_creep_A,
			prng_o => prng_cross_creep_A); -- prng_A

    -- PRNG for r creep crossover
	b2v_inst8 : prng_lfsr
		GENERIC MAP(Nprng => 3)
		PORT MAP(
			clk    => clk,
			reset  => prng_reset,
			enable => Hcros,
			seed   => seed_cross_creep_r,
			prng_o => prng_cross_creep_r); -- prng_r

	-- PRNG for sigmaG2 creep crossover
	b2v_inst9 : prng_lfsr
		GENERIC MAP(Nprng => 3)
		PORT MAP(
			clk    => clk,
			reset  => prng_reset,
			enable => Hcros,
			seed   => seed_cross_creep_s,
			prng_o => prng_cross_creep_s); -- prng_sigmaG2


	----------------------------------------------------------
	-- CREEP CROSSOVER
	----------------------------------------------------------
	-- Creep crossover
	b2v_inst2 : cross_creep
		GENERIC MAP(
			Npadre => 48,
			NParam => 16,
			Nprng  =>  3)
		PORT MAP(
			padre        => P1_reg,
			prng_A       => prng_cross_creep_A,
			prng_r       => prng_cross_creep_r,
			prng_SigmaG2 => prng_cross_creep_s,
			hijo         => hijo_cross_creep ); -- creep crossover offspring

	
	----------------------------------------------------------
	-- PRNG for SHUFFLE CROSSOVER
	----------------------------------------------------------

	-- PRNG for shuffle crossover
	b2v_inst10 : prng_lfsr
		GENERIC MAP(Nprng => 3)
		PORT MAP(
			clk    => clk,
			reset  => prng_reset,
			enable => Hcros,
			seed   => seed_cross_creep_shuf,
			prng_o => prng_cross_shuf);


	----------------------------------------------------------
	-- SHUFFLE CROSSOVER
	----------------------------------------------------------

	-- Shuffle crossover
	b2v_inst3 : cross_shuffle
		GENERIC MAP(
			Npadre => 48,
			NParam => 16)
		PORT MAP(
			bit_rand_A     => prng_cross_shuf(2),
			bit_rand_r     => prng_cross_shuf(1),
			bit_rand_Sigma => prng_cross_shuf(0),
			p1             => P1_reg,
			p2             => P2_reg,
			hijo           => hijo_cross_shuf );-- hijo cross shuffle


	----------------------------------------------------------
	-- PRNG for OFFSPRING MUX
	----------------------------------------------------------

	-- Constant seed for offspring mux PRNG
	b2v_inst17 : entity work.lpm_constant
		GENERIC MAP(LPM_CVALUE => 45, LPM_WIDTH => 7)
		PORT MAP(result => seed_mux_hijos);

	-- PRNG for offspring mux
	b2v_inst25 : prng_lfsr
		GENERIC MAP(Nprng => 7)
		PORT MAP(
			clk    => clk,
			reset  => prng_reset,
			enable => Hcros,
			seed   => seed_mux_hijos,
			prng_o => prng_mux_hijos); -- offspring mux prng


	----------------------------------------------------------
	-- OFFSPRING MUX
	----------------------------------------------------------

	-- Offspring mux
	b2v_inst16 : mux_hijos
		GENERIC MAP(
			Npadre => 48,
			NParam => 16,
			Nprng  =>  7)
		PORT MAP(
			h_bin     => hijo_cross_bin ,
			h_creep   => hijo_cross_creep ,
			h_shuffle => hijo_cross_shuf ,
			p1        => P1_reg,
			p2        => P2_reg,
			val_prng  => prng_mux_hijos,
			o_sel     => gen);
	----------------------------------------------------------
	-- PRNG for MUTATION (With different seeds)
	----------------------------------------------------------

	-- Independent constant seeds
	b2v_seedA : entity work.lpm_constant
	    GENERIC MAP(LPM_CVALUE => 5, LPM_WIDTH => 7)
	    PORT MAP(result => seed_mut_A);

	b2v_seedR : entity work.lpm_constant
	    GENERIC MAP(LPM_CVALUE => 6, LPM_WIDTH => 7)
	    PORT MAP(result => seed_mut_r);

	b2v_seedS : entity work.lpm_constant
	    GENERIC MAP(LPM_CVALUE => 11, LPM_WIDTH => 7)
	    PORT MAP(result => seed_mut_s);

	-- PRNG for A
	b2v_inst23 : prng_lfsr
	    GENERIC MAP(Nprng => 7)
	    PORT MAP(clk => clk, reset => prng_reset, enable => Hpmut, seed => seed_mut_A, prng_o => prng_mutacion_A);

	-- PRNG for r
	b2v_inst22 : prng_lfsr
	    GENERIC MAP(Nprng => 7)
	    PORT MAP(clk => clk, reset => prng_reset, enable => Hpmut, seed => seed_mut_r, prng_o => prng_mutacion_r);

	-- PRNG for sigmaG2
	b2v_inst24 : prng_lfsr
	    GENERIC MAP(Nprng => 7)
	    PORT MAP(clk => clk, reset => prng_reset, enable => Hpmut, seed => seed_mut_s, prng_o => prng_mutacion_s);


	----------------------------------------------------------
	-- MUTATION 
	----------------------------------------------------------

	-- A mutation
	b2v_inst19 : mutacion
	    GENERIC MAP(
		ID     => 0,
		Nmut   => 15,  
		Nparam => 16,
		Nprng  => 7,
		P      => 20)
	    PORT MAP(
		mutate_req => Hpmut,
		gen_in     => gen(47 DOWNTO 32),
		prng_i     => prng_mutacion_A,
		gen_out    => cromosoma(47 DOWNTO 32));

	-- r Mutation 
	b2v_inst20 : mutacion
	    GENERIC MAP(
		ID     => 1,   
		Nmut   => 15,  
		Nparam => 16,
		Nprng  => 7,
		P      => 20)
	    PORT MAP(
		mutate_req => Hpmut,
		gen_in     => gen(31 DOWNTO 16),
		prng_i     => prng_mutacion_r,
		gen_out    => cromosoma(31 DOWNTO 16));

	-- sigmaG2 mutation
	b2v_inst21 : mutacion
	    GENERIC MAP(
		ID     => 2,   
		Nmut   => 12,  
		Nparam => 16,
		Nprng  => 7,
		P      => 20)
	    PORT MAP(
		mutate_req => Hpmut,
		gen_in     => gen(15 DOWNTO 0),
		prng_i     => prng_mutacion_s,
		gen_out    => cromosoma(15 DOWNTO 0));



	-- INDIVIDUAL D Flip-Flop
	-- C9: capture the completed descendant at the end of MUT and freeze it during EVAL.
	cormosoma_reg_enable <= Hpmut;

	b2v_inst27 : entity work.generic_dffe
		GENERIC MAP(WIDTH => 48)
		PORT MAP(
			enable => cormosoma_reg_enable,
			clock  => clk,
			data   => cromosoma,
			q      => individuo);


END bdf_type;
