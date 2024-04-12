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
