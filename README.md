# LCD-Image-Controller
The main purpose of the circuit is to process an 8x8 grayscale image using a series of predefined commands that alter the display in different ways.These operations involve shifting the operation point within the defined coordinate limits, both horizontally and vertically, and determining the maximum, minimum, and average values around the operation point of the image data. Besides the timing constraint for the clock period limited to <strong> 0.44ns </strong>, I utilized power optimization supported by Genus, which reduced the <strong> power consumption from 4.9mW to 4mW. </strong>

## Specification

| Signal Name | I/O | Width | Sample Description |
| :----: | :----: | :----: | :----|
| clk | I | 1 | Clock Signal |
| reset | I | 1 | Reset signal |
| cmd | I | 3 | Command Input Sinal|
| cmd_valid | I | 1 | A high signal indicates that the 'cmd' command input is recognized as valid.|
| IROM_rd | O | 1 | IROM read enable signal |
| IROM_A | O | 6 | IROM address bus |
| IROM_Q | I | 8 | IROM Data Bus|
| IRAM_valid | O | 1 | IRAM data valid signal|
| IRAM_A | O | 6 | IRAM data bus |
| busy | O | 1 | System bus signal |
| done | O | 1 | When the LCD controller completes writing to the IRAM, raising the 'done' signal signifies the completion of the process. |

## Memory Mapping
The grayscale input is configured with an 8x8 pixel resolution, where each pixel is represented by 8 bits of data. Consequently, the grayscale image stored on the Host side comprises a total of 64 pixels. Both the IROM and IRAM have an 8-bit data width and can store 64 addresses. Each address holds 8 bits of data, accurately encoding the grayscale information for a single pixel. This arrangement is illustrated in the image below.
<p align="center">
  <img src="https://github.com/RexJian/LCD-Image-Controller/blob/main/Image/IRAM_IROM_Mapping.png" width="800" height="450" alt="Architecture">
  <br> <strong>Fig1. Input/Output Grayscale Image Memory (IROM / IRAM) Mapping</strong>
</p> 

## Command Definition

The precise functions linked to each input command for the LCD Controller are showed in the table and image below.

<div align="center">
  
| Cmd Number | Control Instruction Description |
| :----: | :----|
| 0(000) | Write |
| 1(001) | Shift Up |
| 2(010) | Shift Down|
| 3(011) | Shift Left|
| 4(100) | Shift Right |
| 5(101)| Max |
| 6(110)| Min |
| 7(111)| Average |
  
</div>

<p align="center">
  <img src="https://github.com/RexJian/LCD-Image-Controller/blob/main/Image/CmdImage.png" width="800" height="450" alt="Architecture">
  <br> <strong>Fig1. Input/Output Grayscale Image Memory (IROM / IRAM) Mapping</strong>
</p> 

