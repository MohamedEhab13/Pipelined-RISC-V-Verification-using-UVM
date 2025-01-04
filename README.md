# RISC-V 5-Stage Pipelined Verification Project

This project focuses on verifying a 5-stage pipelined RISC-V processor using the Universal Verification Methodology (UVM). The verification covers various instruction types and addresses the occurrence of hazards, corner cases, and memory interactions. It uses UVM RAL (Register Abstraction Layer) for memory verification and employs assertions to verify internal control signals.

## Supported Instruction Types

| Instruction Type | Abbreviations                                                              |
|------------------|----------------------------------------------------------------------------|
| **I-type**       | lw, slli, srli, srai, jalr, addi, slti, xori, ori, andi                    |
| **R-type**       | add, sub, sll, slt, xor, srl, sra, or, and                                  |
| **B-type**       | beq, blt, bge, bne                                                         |
| **S-type**       | sw                                                                         |
| **U-type**       | auipc, lui                                                                 |
| **J-type**       | jal                                                                        |

## Test Plan

### 1. **Operations Verification**
   - **Objective**: Ensure that all supported instructions function as expected.
   - **Approach**: Implement a series of tests for each instruction type (I-type, R-type, B-type, S-type, U-type, J-type). Verify that the operations return the correct results in both normal and corner cases.
   - **Test Cases**:
     - Validate basic functionality of each instruction.
     - Test edge cases (e.g., overflow, underflow, negative values).

### 2. **Hazard Occurrence Verification**
   - **Objective**: Detect and resolve data path hazards (e.g., read-after-write, write-after-write) and control hazards (e.g., branch mispredictions).
   - **Approach**: 
     - Test scenarios with data dependencies between instructions to verify proper forwarding and stalling mechanisms.
     - Verify branch instruction handling and the correct resolution of control hazards (e.g., branch prediction, misprediction).
   - **Test Cases**:
     - Create instruction sequences that introduce data hazards (e.g., dependent instructions within pipeline stages).
     - Test branch instructions with different conditions to verify control hazard handling.

### 3. **Corner Case Testing**
   - **Objective**: Ensure the processor behaves correctly in rare or boundary conditions.
   - **Approach**: Develop tests for unusual scenarios, such as the maximum/minimum values for registers and memory, instruction sequences that could expose timing or structural issues, and instruction edge cases.
   - **Test Cases**:
     - Test for unusual register values (e.g., 0, max positive, and max negative).
     - Ensure the processor handles unusual memory patterns correctly.
     - Test the processor with an instruction sequence designed to cause potential conflicts in the pipeline.

### 4. **Memory Verification using UVM RAL**
   - **Objective**: Validate correct memory operations for load and store instructions.
   - **Approach**: Use UVM RAL to abstract memory interactions and verify that the load and store operations work as intended, checking for correct data read/write behavior.
   - **Test Cases**:
     - Verify memory load (`lw`) and store (`sw`) instructions.
     - Test memory interactions with both valid and invalid addresses (e.g., unaligned accesses).
   
### 5. **Internal Control Signal Verification with Assertions**
   - **Objective**: Ensure that the internal control signals function correctly throughout the pipeline.
   - **Approach**: Implement assertions to verify that control signals are correctly generated and propagated during execution.
   - **Test Cases**:
     - Use assertions to check the correctness of control signals like `RegWrite`, `MemRead`, `MemWrite`, etc., for each instruction and pipeline stage.
     - Ensure that all control signals maintain proper timing and synchronization with the pipeline stages.

## Getting Started

1. Clone the repository.
2. Set up the UVM environment as per the UVM standard procedures.
3. Run the UVM testbenches to start the verification process.

### Requirements
- UVM (Universal Verification Methodology)
- Verilog/SystemVerilog
- Simulation tool (e.g., Questa, VCS, or XSIM)

