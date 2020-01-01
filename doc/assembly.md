Device assembly <!-- omit in toc -->
===============

- [Required components](#required-components)
  - [General](#general)
  - [Heater parts](#heater-parts)
- [PCB assembly](#pcb-assembly)
- [Motor & syringe mount](#motor--syringe-mount)
- [Firmware upload](#firmware-upload)


## Required components

### General

&nbsp; | Name | Comment
-------|------|--------
1 | [PCB & Components](https://easyeda.com/reflow/reflow-micro-table) | Go to EasyEda project page and order both in couple of clicks. If you order PCB first, components second, then you will be able to join delivery and save some bucks.
2 | [2.4" Display](https://aliexpress.ru/item/32852776943.html) | 240*320, SPI, ILI9341, touch screen.
3 | [22 AWG wire](https://www.aliexpress.com/item/32854919883.html) | Optional, SMT stencil positioning.
4 | [Milling cutter V-groove 90°](https://www.aliexpress.com/item/32954752325.html) | Countersink for M1.6 flat head screws.
5 | [M1.6 SS screws 20mm](https://www.aliexpress.com/item/33013472653.html) | Mount heater plate to PCB.
6 | [M1.6 SS washers](https://www.aliexpress.com/item/4000222547150.html) |
7 | [M1.6 SS spring lock washers](https://www.aliexpress.com/item/4000222556028.html) |
8 | [Aluminum Foil Tape](https://www.aliexpress.com/item/32895505629.html) | PCB reflective layer.
9 | Aluminum Foil 100μm (0.1mm) | Heater bottom insulation. Such foil is sold for sauna insulation. You can also try 50μm foil from baking forms.

Note. You are strongly advised to order SMT stencil for your PCB. That will
add ~ 8$ in total to your order - good price for convenience. On placing stencil
order at jlcpcb, select option "custom size", and define small one. Then stencil
will be compact and light, with small delivery cost.

### Heater parts

There are 2 possible MCH heater variants:

- With aluminium plate
  - Almost ready (pros).
  - Very cheap (pros).
  - Slower response (cons).
  - May be not available for 110 AC volts (cons).
- With copper plate
  - Very responsive (pros).
  - Good choice of MCH heaters for any voltage and power (pros).
  - More expensive (+20$).
  - Mini circular saw table required (cons).
  - More efforts to build (but still possible for novice).

Please, read separate [heater assembly manual](heater_assembly.md) prior to make
your choice and continue.

Components for "aluminium" heater:

&nbsp; | Name | Comment
-------|------|--------
1 | [Aluminum Heating Plate](https://www.aliexpress.com/item/4000073462890.html) |

Components for "copper" heater:

&nbsp; | Name | Comment
-------|------|--------
1 | [Copper plate 100\*100\*2mm](https://aliexpress.ru/item/32910385579.html) |
2 | [MCH heater 40\*40\*2m 150W](https://aliexpress.ru/item/32918739597.html) |
3 | [M1.6 6mm black screws](https://aliexpress.ru/item/4000217127933.html) | Mount MCH to copper plate
4 | [High-Temp Gasket Maker](https://www.aliexpress.com/item/33005802566.html) | Used as glue for reflective foil borders. Buy any with max temp 340°C or more.


## PCB assembly

TBD


## Motor & syringe mount

TBD


## Firmware upload

TBD
