build:
	$(MAKE) -f Makefile clean
	vivado -mode tcl -source build.tcl -tclargs 0
	xsdk -batch -source sdk.tcl
build-snapshot:
	$(MAKE) -f Makefile clean
	vivado -mode tcl -source build.tcl -tclargs 1
	xsdk -batch -source sdk.tcl
prog:
	program_flash -f ./BOOT.bin -offset 0 -flash_type qspi-x4-single       \
	-fsbl ./pandacam.sdk/zybo_fsbl/Debug/zybo_fsbl.elf                     \
	-blank_check -verify -cable type xilinx_tcf url TCP:127.0.0.1:3121 esn \
	Digilent/210351A6C9FAA/ -debugdevice deviceNr 2
dbg:
	vivado -mode tcl -source connect.tcl
snapshot:
	vivado -mode tcl -source capture.tcl
clean:
	rm -rf .Xil/
	rm -rf BOOT.bin
	rm -rf pandacam*
	rm -rf output.bif
	rm -rf ps_clock_registers.log
	rm -rf vivado*

.PHONY: build build-snapshot prog dbg clean
