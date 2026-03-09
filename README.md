# Pcileech-ISABridge-PC8

Good example of how to use Shadow Configuration, Writemask, and RW1C Masks together to correctly mimick the configuration space of PCI/PCIe devices using PCIleech. Cannot build this device with the core alone as its configuration registers are not a part of a capability list. 

*CHANGE SUBSYSTEM VENDOR ID & SUBSYSTEM ID TO MATCH YOUR SYSTEM ID'S SO THAT IT LOOKS LIKE ITS PART OF YOU'RE MOTHERBOARD OR CHANGE IT TO MATCH THE ID'S OF THE PC8 ISA BRIDGE BEING SIMULATED*

**Info:**

This firmware is based on a datasheet for a chip that was not used for pcie devices but in industrial motherboards and I/O devices. I have implmented PM and PCIe caps so that the device can function as a PCIe device. Datasheet has been provided with the configuration space registers defined.

Driver Scan doesn't detect interrupts being generated, but neither does it complain about it. Interrupts may or may nor be working.

- [Datasheet](PC87200.PDF)

- ![Driver scan after manually setting command register](2.png)

- ![Speed Test](Screenshot%202025-06-10%20160117.png)
