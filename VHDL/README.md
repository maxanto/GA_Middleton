# VHDL Implementation

This folder contains the VHDL implementation of a genetic algorithm for estimating parameters of the Middleton Class A impulsive noise model. The design evaluates 48-bit individuals by comparing the empirical and theoretical complementary cumulative distribution functions (CCDFs) using a sum of absolute differences (SAD).

## Structure

```text
VHDL/
├── README.md
├── constraints/
│   └── zedboard_ga.xdc
└── rtl/
    ├── ga_zedboard_top.vhd
    ├── ga_core.vhd
    ├── control_ga.vhd
    ├── poblacion.vhd
    ├── evol.vhd
    ├── eval.vhd
    ├── eval_elit.vhd
    ├── elit.vhd
    ├── CCDF_empirica.vhd
    ├── ccdf_rom_sync.vhd
    ├── ccdf_samples_pkg.vhd
    ├── ccdf_stream.vhd
    └── ...
```

The files in `rtl/` cover control, population and offspring generation, evaluation, elitism, genetic operators, and supporting blocks. `ccdf_stream.vhd` and several `ccdf_stream_` helper files implement the theoretical CCDF calculation. `ccdf_samples_pkg.vhd` contains the 512 samples used by the synchronous ROM.

## Design flow

1. `poblacion` generates initial 48-bit individuals using three pseudo-random number generators.
2. `eval` calculates the empirical distribution and coordinates `ccdf_stream` to obtain the individual's theoretical distribution.
3. The cost function accumulates the SAD over 512 aligned bin pairs.
4. `elit` keeps the two lowest-cost individuals. `evol` uses offspring selection, crossover, and mutation to produce new individuals; `control_ga` coordinates the stages and generations.
5. When the run finishes, `ga_core` publishes the best individual on `resultado` and asserts `valido`, which remains asserted until reset.

The `ga_core` entity has the generics `Npob` (default 42) and `Ngen` (default 120). Its `rst` input is an asynchronous, active-low reset. `resultado` is 48 bits wide, divided into three 16-bit fields for the individual parameters (`A`, `r`, and `SigmaG2`).

## ZedBoard Integration

The top-level entity is `ga_zedboard_top`. It exposes the `clk` clock and the `SW0` switch; the 48-bit result and the `valido` signal are connected to `ila_0` for internal observation. The Vivado project must provide an ILA IP named `ila_0` with a 48-bit `probe0` and a 1-bit `probe1`; this IP is not defined in the VHDL files in this folder.

The `constraints/zedboard_ga.xdc` file assigns `clk` to the 100 MHz clock on the ZedBoard Rev. C/D (Y9) and `SW0` to pin F22. `SW0 = 0` holds the design in reset, while `SW0 = 1` allows it to run.

## Simulation and Synthesis

This folder does not include simulation scripts, testbenches, or a Vivado project. To set up a project:

1. Add the VHDL files in `rtl/` to a `work` library, including the generated helper blocks used by `ccdf_stream`.
2. For a board implementation, configure the `ila_0` IP described above, select `ga_zedboard_top` as the top-level entity, and add `constraints/zedboard_ga.xdc`.
3. Compile and run simulation or synthesis with your chosen tool. Check the Vivado reports to verify the implementation and clock constraints.

For an overview of the repository and the Python simulation, see the [main README](../README.md).
