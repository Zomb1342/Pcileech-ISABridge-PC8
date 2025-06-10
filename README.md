# Pcileech-ISABridge-PC8

FPGA mimicking a PCI - ISA Bridge. Has not been tested thrououghly and has been made for researching purposes only; I do know it is no beuno for VGK in its current state.

Issues with firmware in its current state:

1.) Command Register is zero'd out when driver loads; I cannot seem to get it to set the command register. If you set the command register manually using software it will pass the driver test & it passes the speed test with flying colors. 
If you can figure out how to fix the command register I'd happily commit it to this repo. 

2.) Interrupts are not firing; I believe this is because the Command Register is not initializing to the correct value upon startup so the int_line value assigned is FF which is invalid.
Maybe can change interrupts from Legacy to MSI to generate Interrupts but I would think if the Command Register is causing the issue then using MSI would not fix the interrupt issue.

More Info:

This firmware is based on a datasheet for a chip that was not used for pcie devices but in industrial motherboards and I/O devices that required an ISA Bridge. Datasheet has been provided.

The I/O Bar is unneccessary and I only implemented because the datasheet shows in the command register than the I/O bar should be enabled.

Both the Caps & Extended Caps I implemented from scratch as the datasheet does not have that information included; If you create firmware from this device without the capabilities included it will fail the driver scan with a capability error as well as 
fail to initialize the linking speed/width. 

![Driver scan before manually setting command register](image.png)

![Driver scan after manually setting command register](2.png)

![Speed Test](Screenshot%202025-06-10%20160117.png)

[Datasheet](PC87200.PDF)
