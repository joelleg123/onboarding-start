<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project works by taking in the following inputs: COPI, nCS, SCLK which are synchronized using a 2-stage flip-flop chain (a CDC). These inputs are used to configure the ourputs as defined by the mode.

## How to test

In order to test the PWM module, perform a duty cycle sweep from 0x00 to 0xFF, check the interaction between the output enable and the PWM enable registers, and finally verify the frequency and the PWM Duty cycle.

To test the SPI module, check address handling, write to a register, assert uo_out and uio_out, execute an SPI transaction.

## External hardware

This project uses the following external hardware: This will be updated later.
