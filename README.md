# VHDL_IP_LIB
**This GIT repository has the goal to design mutiple IP with various interfaces to developed my knowledge in design**
## AES-256 IP with AXI4-Lite Interface 
### Overview
This document provides an overview of the AES-256 IP core with AXI4-Lite interface, detailing its features and implementation specifics.

### Features
- **AES-256 Encryption**:
  - Supports robust 256-bit key encryption for secure data protection.
  
- **AXI4-Lite Interface**:
  - Facilitates seamless integration with both FPGA and ASIC designs.
  - Ensures efficient communication with the AES-256 IP core.

### Implementation Details
- **Core Design**
    - The AES-256 IP core is designed to be vendor-agnostic, ensuring compatibility across various FPGA and ASIC platforms.
    - The modular architecture allows for easy integration into existing designs.

- **AXI4-Lite Interface**
    - Provides a straightforward and efficient method for interfacing with the AES-256 IP core.
    - Simplifies the communication process, enhancing overall system performance.

## System Management Bus IP with Wishbone Interface
### Overview 
This document provides an overview of the AES-256 IP core with AXI4-Lite interface, including its features, implementation details.
### Features
- **SMBus Controller**:
  - Supports SMBus 2.0 protocol
  - Master and Slave modes
  - Clock stretching and arbitration
  - Packet error checking (PEC)
  - Configurable clock frequency

- **Wishbone Interface**:
  - Compliant with Wishbone B3 specification
  - Supports 8 data transfers
  - Interrupt support

### Implementation Details
- **Core Architecture**:
  - Modular design for easy integration
  - Low-latency data path
  - Optimized for FPGA and ASIC implementations

- **Configuration Options**:
  - Parameterizable core settings
  - Support for various clock domains
  - Customizable address mapping