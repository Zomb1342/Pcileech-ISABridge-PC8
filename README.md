# Pcileech-ISABridge-PC8

FPGA mimicking a PCI - ISA Bridge. Has not been tested thrououghly and has been made for researching purposes only; I do know it is no beuno for VGK or EAC in its current state.

Issues with firmware in its current state:

1.) Interrupts are not firing. The device will not be assigned a valid int_line value so I do not think it can generate interrupts.
- Possible Fix -
- Manually build msi cap in the core and attempt to use msi interrupts.

More Info:

This firmware is based on a datasheet for a chip that was not used for pcie devices but in industrial motherboards and I/O devices that required an ISA Bridge. Datasheet has been provided.

I implemented the caps from scratch as the datasheet does not have that information included; If you create firmware from this device without the capabilities included it will fail the driver scan with a capability error as well as fail to show as a pcie device in system manager, and none of the linking information will be available.

![Driver scan after manually setting command register](2.png)

![Speed Test](Screenshot%202025-06-10%20160117.png)

[Datasheet](PC87200.PDF)
