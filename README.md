# Traffic Light Controller with Ambulance Priority (Verilog)

A Verilog-based traffic light controller implementing a standard NS/EW
signal cycle with an emergency-vehicle (ambulance) priority override,
modeled as a hardware Finite State Machine (FSM).

## Problem Statement

Delays at red lights measurably worsen ambulance response times, and
ambulances running red lights are statistically involved in more
severe accidents than other emergency-vehicle incidents. Most existing
solutions (YOLOv5/v8-based camera detection + Arduino/Raspberry Pi
control) implement the signal-switching logic in software running on
a general-purpose microcontroller.

This project implements the **control logic itself as a dedicated
hardware FSM**, giving deterministic, glitch-free timing with no OS
or software-loop jitter — intended to sit downstream of a
camera/YOLO-based ambulance-detection module (simulated here as a
simple digital input signal).

## Architecture
Camera + YOLOv8 Ambulance Detector --> ambulance_ns / ambulance_ew (digital signal)
|
v
Verilog FSM Traffic Light Controller
|
v
ns_light[1:0] / ew_light[1:0]

## FSM States

| State        | Meaning                              |
|--------------|---------------------------------------|
| NS_GREEN     | North-South green, East-West red      |
| NS_YELLOW    | North-South yellow (transition)       |
| EW_GREEN     | East-West green, North-South red      |
| EW_YELLOW    | East-West yellow (transition)         |
| AMB_NS       | Ambulance override — NS forced green  |
| AMB_EW       | Ambulance override — EW forced green  |

Normal cycle: `NS_GREEN -> NS_YELLOW -> EW_GREEN -> EW_YELLOW -> ...`
On ambulance detection, the FSM transitions to the matching AMB_* state
and holds green until the ambulance signal clears, then resumes the
normal cycle.

## Repository Structure
traffic-light-controller/
├── src/
│ └── traffic_light_controller.v # FSM design
├── tb/
│ └── tb_traffic_light.v # Testbench
├── .gitignore
└── README.md

## How to Run (Icarus Verilog)

```bash
iverilog -o sim src/traffic_light_controller.v tb/tb_traffic_light.v
vvp sim
gtkwave traffic.vcd
```

In GTKWave, add `clk`, `rst`, `ambulance_ns`, `ambulance_ew`,
`ns_light`, `ew_light`, `state` to the Signals panel and zoom to fit.

## Simulation Result

*(Add your GTKWave screenshot here, e.g.* `![waveform](docs/waveform.png)` *)*

## Future Scope

- Real camera + YOLOv8 ambulance detection feeding the `ambulance_*` inputs
- Extend to a full 4-way intersection
- FPGA synthesis (Vivado) with resource/timing report
- Multi-ambulance arbitration (simultaneous detection on both roads)

## Author

Shridhar Sharma — Madhav Institute of Technology & Science (MITS), Gwalior
Anant Sharma - Madhav Institute of Technology & Science (MITS), Gwalior