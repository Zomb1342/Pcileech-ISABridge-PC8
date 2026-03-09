# Pcileech-ISABridge-PC8

Good example of how to use Shadow Configuration, Writemask, and RW1C Masks together to correctly mimick the configuration space of PCI/PCIe devices using PCIleech. You cannot mimick this device by using the core alone as its configuration registers are not a part of a capability list. 

# **WARNING**
- *CHANGE SUBSYSTEM VENDOR ID & SUBSYSTEM ID TO MATCH THAT OF ONE OF YOUR ON-BOARD PCIe DEVICES SO THAT IT LOOKS LIKE ITS PART OF YOU'RE SYSTEM OR CHANGE IT TO MATCH THE ID'S OF THE PC8 ISA BRIDGE. WHICHEVER YOU THINK IS BEST AS THE B:D:F WOULD GIVE AWAY THE FACT THE DEVICE IS NOT AN ON-BOARD PCIe DEVICE IF PROBED OR REVIEWED MANUALLY*

# **Info:**

This firmware is based on a datasheet for a chip that was not used for pcie devices but in industrial motherboards and I/O devices. I have implmented PM and PCIe caps so that the device can function as a PCIe device. Datasheet has been provided with the configuration space registers defined.

Driver Scan doesn't detect interrupts being generated, but neither does it complain about it. Interrupts may or may nor be working.

- [Datasheet](PC87200.PDF)

- ![Driver scan after manually setting command register](2.png)

- ![Speed Test](Screenshot%202025-06-10%20160117.png)
