# PCILeech-ISABridge-PC8

Example firmware demonstrating how to use **Shadow Configuration**, **Write Mask**, and **RW1C masks** together to accurately mimic the configuration space of a PCI/PCIe device using PCILeech.

This device **cannot be replicated using the PCIe core alone**, because its configuration registers are **not part of a capability list** and must be implemented manually.

---

# Warning

- Change the **Subsystem Vendor ID** and **Subsystem Device ID** to match either:
  - one of your **existing onboard PCIe devices**, or  
  - the IDs used by the **PC8 ISA Bridge**.

- Otherwise, the **Bus:Device:Function (B:D:F)** address may reveal that the device is not actually integrated into the motherboard if the system configuration is manually inspected.

- No PCI/PCIe **capabilities** are currently implemented because a real ISA bridge would not normally expose them. In this state, the device **fails Driver Scan**.

If **Power Management (PM)** and **PCIe capabilities** are implemented so the device behaves as a PCIe endpoint (as shown in the screenshot below), the device **passes Driver Scan**.

Determining the appropriate configuration depends on your research goals.

**Driver Scan results should not be considered authoritative.**

---

# Information

This firmware is based on the datasheet of a chip originally designed for **industrial motherboards**, not PCIe devices.

The referenced datasheet includes definitions for the configuration space registers used in this firmware.

---

### Interrupt Behavior

Driver Scan does not detect interrupts being generated, but it also does not report an error related to interrupts.  
Interrupt functionality **may or may not be working**.

---

### Resources

- [Datasheet](PC87200.PDF)

---

### Screenshots

Driver Scan:

![Driver Scan](2.png)

Speed Test:

![Speed Test](Screenshot%202025-06-10%20160117.png)
