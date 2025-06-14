# Pcileech-ISABridge-PC8

FPGA mimicking a PCI - ISA Bridge. Has not been tested thrououghly and has been made for researching purposes only; I do know it is no beuno for VGK or EAC in its current state.

**Issues with firmware in its current state:**

- Interrupts are not firing. I had to manually configure an in_line value in the cfg_a7.sv file otherwise it gets set to 0xFF.
- Driver shows no issues in device manager, IRQ gets assigned to the correct value in the resources tab.
- Get-PnpDevice | Where-Object { $_.InstanceId -match "VEN_XXXX" } | Format-List *  I input this command in the Powershell & found an error "CM_PROB_PHANTOM"

Code 45 - CM_PROB_PHANTOM
03/13/2023
This Device Manager error message indicates that the device is not present.

Error Code
45

Display Message
"Currently, this hardware device is not connected to the computer. (Code 45)"

"To fix this problem, reconnect this hardware device to the computer."

Recommended Resolution
None. This problem code should only appear when the DEVMGR_SHOW_NONPRESENT_DEVICES environment variable is set.


More Info:

This firmware is based on a datasheet for a chip that was not used for pcie devices but in industrial motherboards and I/O devices that required an ISA Bridge. Datasheet has been provided.

I implemented the caps from scratch as the datasheet does not have that information included; If you create firmware from this device without the capabilities included it will fail the driver scan with a capability error as well as fail to show as a pcie device in system manager, and none of the linking information will be available.

![Driver scan after manually setting command register](2.png)

![Speed Test](Screenshot%202025-06-10%20160117.png)

[Datasheet](PC87200.PDF)
