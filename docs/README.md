# 📚 Documentation

This folder contains complementary documentation for the project, including architectural descriptions, diagrams, and explanations of the main blocks of the genetic algorithm and its hardware implementation.

The main `README.md` at the repository root provides a general overview. This folder goes deeper into the design and validation details.

## 📂 Folder Structure

```
docs/
├── arquitectura_general/      # General system architecture
├── fsm/                       # Finite state machine (FSM) documentation
├── Proceso_evolutivo/         # Evolutionary process description
├── Operador_binario/          # Binary genetic operator documentation
├── Operador_vecindad/         # Neighborhood operator documentation
├── Bloque funcion de costo/   # Cost / fitness function block documentation
└── Elitismo_y_guardado/       # Elitism and best-individual storage documentation
```

> Folder names are kept in Spanish to match the original project structure.

## 📖 Contents Overview

| Folder | Description |
|---|---|
| `arquitectura_general/` | General architecture of the system for hardware implementation, including block diagrams and high-level descriptions. |
| `fsm/` | Finite state machine (FSM) design, state diagrams, and control flow explanations. |
| `Proceso_evolutivo/` | Description of the evolutionary process, including generation flow and algorithm behavior. |
| `Operador_binario/` | Documentation for the binary genetic operator used in the algorithm. |
| `Operador_vecindad/` | Documentation for the neighborhood-based genetic operator. |
| `Bloque funcion de costo/` | Explanation of the cost / fitness function block and its evaluation logic. |
| `Elitismo_y_guardado/` | Elitism strategy and storage of the best individuals across generations. |

## 🖼️ Diagrams and Figures

This folder includes diagrams, block diagrams, and state machines used during the design and validation of the system. Figures are stored alongside their corresponding documentation subfolders when possible.

> If a dedicated `assets/` or `figures/` folder is added in the future, image references will be updated accordingly.

## 📝 Notes

- This documentation is intended to support both the Python simulation and the VHDL hardware implementation.
- Some sections may be updated as the project evolves.
- For the overall project description, refer to the main [README](../README.md).

---

[⬅️ Back to main README](../README.md)
