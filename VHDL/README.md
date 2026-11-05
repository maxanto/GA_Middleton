# ⚙️ VHDL Implementation

This folder contains the VHDL hardware description of the genetic algorithm architecture used for Middleton Class A noise parameter estimation.

The design is organized into functional blocks that separate control, genetic operators, memory, fitness evaluation, and top-level integration.

## 📂 Folder Structure

```
vhdl/
├── control/                 # Control unit and finite state machine (FSM)
├── operadores_geneticos/    # Genetic operators (selection, crossover, mutation)
├── memoria/                 # Memories, registers, and auxiliary storage
├── fitness/                 # Fitness / cost function evaluation
└── top/                     # Top-level integration
```

> Folder names are kept in Spanish to match the original project structure.

## 🧩 Functional Blocks

| Folder | Description |
|---|---|
| `control/` | Control unit and finite state machine (FSM) that coordinate the evolutionary process. |
| `operadores_geneticos/` | Hardware implementation of the genetic operators used by the algorithm. |
| `memoria/` | Memories and registers used to store the population, parameters, and intermediate results. |
| `fitness/` | Fitness / cost function evaluation block. |
| `top/` | Top-level module that integrates the complete system. |

## 🔌 Top-Level Module

The top-level design is located in:

```
vhdl/top/
```

The exact top-level entity name and port list depend on the current implementation. Refer to the source files in this folder for the final interface definition.

## 🛠️ Simulation and Synthesis

The design can be simulated and synthesized using standard VHDL tools:

| Tool | Purpose |
|---|---|
| ModelSim / QuestaSim | Behavioral and functional simulation |
| Vivado / Quartus | FPGA synthesis and implementation |

Typical workflow:

1. Create a project in your simulation or synthesis tool.
2. Add the VHDL source files from the corresponding folders.
3. Set the top-level entity from `vhdl/top/`.
4. Compile, elaborate, and run the simulation.
5. Apply synthesis constraints if targeting an FPGA.

> Simulation scripts, testbenches, and constraints may be added as the project evolves.

## 📝 Notes

- The implementation is currently under development.
- File and folder names may be updated as the architecture is refined.
- Refer to the main README for the overall project description and Python simulation.

---

[⬅️ Back to main README](../README.md)
