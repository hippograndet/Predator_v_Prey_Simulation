# Predator-Prey Agent-Based Simulation

> A Master's Dissertation project implementing an evolutionary agent-based simulation using the [GAMA Platform](https://gama-platform.org/). Predators and prey are autonomous agents driven by neural networks that evolve across generations via a genetic algorithm — producing emergent pursuit, evasion, and population dynamics.

---

## Key Features

- **Neural network brains** — each agent perceives its environment through raycasting sensors and acts via a configurable feedforward neural network (variable hidden neurons, optional memory)
- **Genetic algorithm evolution** — traits that evolve across generations include: neural network weights, body size, sensor range/angle, attack/defense stats, and hidden neuron count
- **Raycasting perception** — agents cast rays in a configurable arc to detect nearby entities (prey, predators, terrain), extracting distance and angle features as neural network inputs
- **Configurable terrain** — an optional mountain obstacle (circle, square, or line) reduces agent speed, visibility, and health within its bounds
- **Rich real-time visualisation** — population charts, predator-to-prey ratio, neural network output heatmaps, and optional per-agent health/energy bars and sensor ray display
- **Energy economy** — agents pay energy costs for movement and "thinking" (proportional to brain complexity), incentivising efficient neural architectures
- **Prey suffocation** — overcrowded prey die from density pressure, preventing runaway population explosions
- **CSV logging** — final simulation statistics are exported for offline analysis

---

## Demo

> Screenshots and GIFs of the simulation running should be placed in [`docs/figures/`](docs/figures/). See [Adding Visuals](#adding-visuals) below.

---

## Getting Started

### Prerequisites

- [GAMA Platform 2025.6.4](https://gama-platform.org/download) with the bundled JDK

### Running the Simulation

1. Clone or download this repository to a local folder
2. Open GAMA and, when prompted to select a workspace, **point it to the root of this repository** (the folder containing `gama/` and this README)
3. GAMA will automatically detect the project as a **User Model** named `Predator_v_Prey`
4. In the GAMA navigator panel, open:
   `User Models / Predator_v_Prey / models / Predator_Prey.gaml`
5. In the file, locate the **`Simulation_Testing`** experiment at the bottom and click the green **Run** button
6. The simulation map and all visualisation charts will open automatically

### Adjusting Parameters

Once the `Simulation_Testing` interface is open, a **Parameters** panel lets you tune the simulation before or between runs. Parameters are grouped by category — see the [Configuration Parameters](#configuration-parameters) table below for what each one controls.

---

## Simulation Architecture

```
Environment (100×100 grid, optional mountain obstacle)
        │
  ┌─────┴──────┐
  │   prey     │   ←── blue agents
  │ predator   │   ←── red agents
  └─────┬──────┘
        │
  ┌─────▼──────────────────────────────────┐
  │  Raycasting Sensors                    │
  │  (configurable arc, range, precision)  │
  └─────┬──────────────────────────────────┘
        │  distance + angle features per ray group
  ┌─────▼──────────────────────────────────┐
  │  Feedforward Neural Network            │
  │  inputs: status features + ray groups  │
  │  hidden: 0–12 neurons (evolvable)      │
  │  outputs: Δheading, speed              │
  └─────┬──────────────────────────────────┘
        │
  ┌─────▼──────────────────────────────────┐
  │  Genetic Algorithm (on death/birth)    │
  │  Gaussian mutation on weights + traits │
  └────────────────────────────────────────┘
```

---

## Configuration Parameters

All parameters are exposed in the GAMA experiment GUI under labelled categories.

| Category | Parameter | Default | Description |
|---|---|---|---|
| Environment | Environment Size | 100 | Grid side length (50–1000) |
| Environment | Population per 10² | 0.5 | Agent density |
| Environment | Predator Proportion | 0.33 | Fraction of agents that are predators |
| Environment | Add Mountain | true | Enable terrain obstacle |
| Agent Sensors | Sensor Distance | 15× body radius | Ray cast reach |
| Agent Sensors | Sensor Angle | 180° | Arc covered by sensor rays |
| Agent Sensors | Sensor Precision | 2.0 | Angular resolution (smaller = more rays) |
| Agent Brain | Hidden Neurons | 0 | Starting hidden layer size |
| Agent Brain | Sensor Groups | 3 | How many ray groups feed the network |
| Agent Brain | Use Memory | false | Recurrent hidden state |
| Agent Evolution | Evolve Weights | true | Mutate NN weights each generation |
| Agent Evolution | Evolve Sensors | false | Mutate sensor range/angle |
| Agent Evolution | Evolve Body Radius | false | Mutate agent body size |
| Agent Evolution | Evolution Std | 0.1 | Gaussian mutation standard deviation |
| Agent Evolution | Evolution Decay | 0.99 | Mutation std decay per generation |
| Species Specific | Prey Resting Energy | 1/10 | Energy recovered per rest cycle |
| Species Specific | Predator Digestion | 1/3 | Fraction of prey energy absorbed per cycle |

---

## Project Structure

```
.
├── gama/
│   ├── models/
│   │   └── Predator_Prey.gaml   # Full simulation model (GAML)
│   └── includes/
│       ├── energy_icon.png      # UI overlay icon
│       └── health_icon.png      # UI overlay icon
├── docs/
│   └── figures/                 # Screenshots and GIFs (add your own)
├── s1849145.pdf                 # Full dissertation
├── README.md
└── LICENSE
```

---

## Adding Visuals

To add screenshots or a GIF of the running simulation:

1. Run the simulation in GAMA (autosave is enabled — PNGs are written to the working directory automatically)
2. Copy images into [`docs/figures/`](docs/figures/)
3. Reference them in this README with `![caption](docs/figures/filename.png)`

A GIF showing agents evolving pursuit/evasion behaviours over generations is particularly effective for communicating the project quickly.

---

## Citation

If you use or reference this work, please cite:

```bibtex
@mastersthesis{grandet2024predatorprey,
  author  = {Hippolyte Grandet},
  title   = {Predator and Prey, Agent-Based Simulation},
  school  = {University of Edinburgh},
  year    = {2024},
  note    = {MSc Dissertation, Student ID: s1849145}
}
```

> Please update the school name and year if they differ.

---

## License

This project is licensed under the [MIT License](LICENSE).
