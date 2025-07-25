# Pcileech-ISABridge-PC8

FPGA mimicking a PCI - ISA Bridge.

**Issues with firmware in its current state:**
- Device Driver shows no errors or issues but when searching for errors in the command prompt with this command:
"Get-PnpDevice | Where-Object { $_.InstanceId -match "VEN_XXXX" } | Format-List * " 
I get the error "CM_PROB_PHANTOM"

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

***Its possbile that either this device does not generate interrupts or generates interrupts on a lower level that dvrscan doesn't detect***

**More Info:**

This firmware is based on a datasheet for a chip that was not used for pcie devices but in industrial motherboards and I/O devices that required an ISA Bridge. Datasheet has been provided.

I implemented the caps from scratch as the datasheet does not have that information included as this is supposed to be a PCI device and not a PCIE device. You can implement it without the caps enabled but you will fail the driver scan.

Driver Scan doesn't detect interrupts being generated, I believe this is because this device does not use a driver but communicates on a lower level. I could be wrong in this logic though. 

![Driver scan after manually setting command register](2.png)

![Speed Test](Screenshot%202025-06-10%20160117.png)

[Datasheet](PC87200.PDF)
