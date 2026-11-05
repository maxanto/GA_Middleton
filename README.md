# 🧬 Genetic Algorithm for Middleton Class A Noise Estimation

Implementation and validation of an architecture based on genetic algorithms for parameter estimation of the Middleton Class A impulsive noise model.

## 📖 Description

This repository contains the complete development of the analysis, simulation, and hardware implementation of a genetic algorithm applied to Middleton Class A noise estimation.

The project includes:

- 🐍 Simulations developed in Python/Jupyter Notebook.
- ⚙️ Hardware descriptions in VHDL.
- 🖼️ Block diagrams and system architecture.

## 📂 Repository Structure

```
.
├── notebooks/
│   └── Algoritmos_geneticos.ipynb
│
├── vhdl/
│   ├── control/
│   ├── operadores_geneticos/
│   ├── memoria/
│   ├── fitness/
│   └── top/
│
├── Readme/
│   ├── arquitectura_general/
│   ├── fsm/
│   ├── Proceso_evolutivo/
│   ├── Operador_binario/
│   ├── Operador_vecindad/
│   ├── Bloque funcion de costo/
│   └── Elitismo_y_guardado/
│
└── README.md
```

## 🧪 Python Simulation

The main notebook contains:

✔️ Middleton Class A noise modeling  
✔️ Genetic algorithm implementation  
✔️ Convergence evaluation  
✔️ Result validation  
✔️ Performance analysis

📄 Main file:

`/notebooks/Algoritmos_geneticos.ipynb`

## ⚙️ Hardware Implementation

The hardware implementation was developed in VHDL and includes several functional blocks of the system:

- Control unit
- Finite state machine (FSM)
- Genetic operators
- Fitness evaluation
- Memories and auxiliary registers
- Top-level integration

📁 Source code:

`/vhdl`

## 🖼️ Figures and Documentation

The repository includes graphical documentation used during design and validation:

- General architecture of the system for hardware implementation
- Block diagrams
- State machines

📁 Directory:

`/figures`

## 🎯 Project Objective

Develop an efficient hardware architecture based on genetic algorithms for estimating parameters associated with the Middleton Class A impulsive noise model, with the possibility of FPGA implementation.

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| Python | Simulation and validation |
| Jupyter Notebook | Algorithm development |
| VHDL | Hardware implementation |
| ModelSim / QuestaSim | Digital simulation |
| Vivado / Quartus | FPGA synthesis |

## 🚧 Project Status

Project currently under development
