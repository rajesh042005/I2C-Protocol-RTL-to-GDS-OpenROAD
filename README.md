<h1 align="center">I2C Protocol Design in Verilog</h1>

<p align="center">
<b>RTL Implementation • FSM Driven • Open-Drain Bus • OpenROAD Verified</b>
</p>

<p align="center">

<img src="https://img.shields.io/badge/I2C-Bus%20Protocol-1f6feb?style=for-the-badge"/>
<img src="https://img.shields.io/badge/RTL-Design-ff7b00?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Verilog-HDL-2ea44f?style=for-the-badge"/>
<img src="https://img.shields.io/badge/OpenROAD-ASIC%20Flow-8250df?style=for-the-badge"/>

</p>

<p align="center">

<img src="https://img.shields.io/badge/Status-Complete-success?style=flat-square"/>
<img src="https://img.shields.io/badge/Stage-RTL→GDS-blue?style=flat-square"/>
<img src="https://img.shields.io/badge/Tech-Sky130HD-informational?style=flat-square"/>

</p>

---

<p align="center">
A structured implementation of the <b>I2C communication protocol</b> in Verilog, focusing on accurate bus behavior, modular FSM design, and successful ASIC flow validation using OpenROAD.
</p>

---

##  Why Not SPI? 

Before choosing I2C, it's important to understand the limitations of the SPI (Serial Peripheral Interface) protocol:

### 🔻 Disadvantages of SPI

- **More Wires Required**
  - SPI needs **4 signals**:
    - MOSI (Master Out Slave In)
    - MISO (Master In Slave Out)
    - SCLK (Clock)
    - SS (Slave Select)

- **Scalability Issue**
  - Each slave requires a **separate SS (chip select) line**
  - For *N slaves → N extra wires*
  - Becomes complex in large systems

- **No Addressing Mechanism**
  - SPI does **not support addressing**
  - Master must manually select each slave

- **Higher Pin Usage**
  - Not ideal for ASICs or compact embedded designs where **pin count is critical**

---

### Why I2C is Preferred

The I2C (Inter-Integrated Circuit) protocol solves these issues:

- **Only 2 wires** → SCL (clock) and SDA (data)
- **Supports multiple slaves using addressing**
- **No need for multiple chip select lines**
- **Efficient for on-chip and low-speed communication**
- **Widely used in embedded and ASIC designs**

---

###  Design Motivation

This project focuses on I2C because it provides:

- **Reduced wiring complexity**
- **Better scalability**
- **Cleaner bus architecture for ASIC implementation**

---

## Overview

RTL implementation of the I2C protocol to demonstrate:
- Master–Slave communication  
- Open-drain SDA behavior  
- FSM-based protocol control  

---

## I2C Basics

| Signal | Role |
|--------|------|
| SCL    | Clock (Master) |
| SDA    | Data (Shared)  |

---

## Open-Drain SDA

<img src="https://storage.googleapis.com/skill-accelerator/public/articles/i2c/text/0-SDA-open-drain-configuration.png" height="300">

- Devices **only pull LOW (0)**  
- HIGH is via **pull-up resistor**  

| Condition | SDA |
|----------|-----|
| Any device pulls LOW | 0 |
| None pulls LOW       | 1 |

### RTL Mapping

```verilog
assign sda_in =
    ( (sda_master_oe && (sda_master_out == 0)) ||
      (sda_slave_oe  && (sda_slave_out  == 0)) )
    ? 1'b0 : 1'b1;
```

---

## Protocol Flow

```
START → ADDRESS + R/W → ACK → DATA → ACK → STOP
```

- START: SDA ↓ while SCL ↑  
- STOP: SDA ↑ while SCL ↑  

---

## Design

<img src="https://storage.googleapis.com/skill-accelerator/public/articles/i2c/text/0-0-I2C-Communication.png" height="300">

---

## Modules

### i2c_top.v
- Bus connection  
- SDA sharing logic  

### i2c_master.v
- Generates SCL  
- Controls protocol  
- Handles read/write  

FSM:
```
IDLE → START → ADDR → ACK1 → DATA → ACK2 → STOP
```

### i2c_slave.v
- Detects START/STOP  
- Matches address  
- Sends ACK / data  

FSM:
```
IDLE → ADDR → ACK → DATA → ACK
```

---

## Operation

### Write
>START → ADDR → ACK → DATA → ACK → STOP  

### Read
>START → ADDR → ACK → DATA → STOP  

---

## Key Points

- SDA is **shared and bidirectional**  
- LOW dominates on bus  
- Master controls timing  
- Slave responds  
- FSM drives protocol  

---

## Results (OpenROAD)

### 🔹 Timing
        "finish__timing__setup__ws": 8.58929 (MET)
        "finish__timing__hold__ws": 0.470924 (MET)

### 🔹 Area
        "finish__design__instance__count__stdcell": 406
        "finish__design__instance__area__stdcell": 3504.61
        "Design area: 3377 um^2, 43% utilization
    
### 🔹 Physical
- Placement:

        "flow__warnings__count": 0,
        "flow__errors__count": 0,
        "flow__warnings__type_count": 0
  
- Routing:

        "detailedroute__route__drc_errors__iter:3": 0
        "detailedroute__flow__errors__count": 0

- DRV: 

        "finish__timing__drv__setup_violation_count": 0,
        "finish__timing__drv__hold_violation_count": 0,

### 🔹 Final Design
- Outputs: `6_final.odb`

<img width="1800" height="1000" alt="image" src="https://github.com/user-attachments/assets/67ee4959-5a58-4cc5-b3ca-5ba774cfc185" />

>Final optimized layout after timing closure with improved slack and verified design integrity.


- Outputs: `6_final.gds`

<img width="1800" height="1000" alt="image" src="https://github.com/user-attachments/assets/24e06d18-9eb2-433f-9013-b03991f889d3" />

>Generated GDSII layout representing the tape-out ready physical design for fabrication.

---

<h4 align="center">Successfully implemented and validated an end-to-end I2C ASIC design flow, from RTL modeling to GDSII generation, ensuring timing closure and design integrity.</h4>

---
