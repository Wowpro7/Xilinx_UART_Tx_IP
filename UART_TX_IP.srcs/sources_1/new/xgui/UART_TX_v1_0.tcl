# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Description [ipgui::add_page $IPINST -name "Description"]
  ipgui::add_static_text $IPINST -name "text" -parent ${Description} -text {PARAMETERS:
* DATA_SIZE = Data input vector size.
* PARITY_ENABLE         =Enables the parity bit.
* PARITY_ODD_EVEN   = Parity bit is odd or even.
* STOP_BITS                   = How many bits.
* SYSTEM_CLOCK        = Speed of input Clock.
* UART_BAUDRATE    = UART Clock speed.

INPUT:
* iSystem_Clock = System clock at which data will arrive at and the source of creating UART Clock.
* iReset = System Reset.
* iValid_Data = input bit indicating data is ready.
* iData = Data to send.

OUTPUT:
* oData = tx data output.
* oBusy = rising to 1 when sending data and cant read data.}

  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Configure Parameters}]
  ipgui::add_param $IPINST -name "SYSTEM_CLOCK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "UART_BAUDRATE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PARITY_ENABLE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "PARITY_ODD_EVEN" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "STOP_BITS" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.PARITY_ENABLE { PARAM_VALUE.PARITY_ENABLE } {
	# Procedure called to update PARITY_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PARITY_ENABLE { PARAM_VALUE.PARITY_ENABLE } {
	# Procedure called to validate PARITY_ENABLE
	return true
}

proc update_PARAM_VALUE.PARITY_ODD_EVEN { PARAM_VALUE.PARITY_ODD_EVEN } {
	# Procedure called to update PARITY_ODD_EVEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PARITY_ODD_EVEN { PARAM_VALUE.PARITY_ODD_EVEN } {
	# Procedure called to validate PARITY_ODD_EVEN
	return true
}

proc update_PARAM_VALUE.STOP_BITS { PARAM_VALUE.STOP_BITS } {
	# Procedure called to update STOP_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STOP_BITS { PARAM_VALUE.STOP_BITS } {
	# Procedure called to validate STOP_BITS
	return true
}

proc update_PARAM_VALUE.SYSTEM_CLOCK { PARAM_VALUE.SYSTEM_CLOCK } {
	# Procedure called to update SYSTEM_CLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SYSTEM_CLOCK { PARAM_VALUE.SYSTEM_CLOCK } {
	# Procedure called to validate SYSTEM_CLOCK
	return true
}

proc update_PARAM_VALUE.UART_BAUDRATE { PARAM_VALUE.UART_BAUDRATE } {
	# Procedure called to update UART_BAUDRATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UART_BAUDRATE { PARAM_VALUE.UART_BAUDRATE } {
	# Procedure called to validate UART_BAUDRATE
	return true
}


proc update_MODELPARAM_VALUE.SYSTEM_CLOCK { MODELPARAM_VALUE.SYSTEM_CLOCK PARAM_VALUE.SYSTEM_CLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SYSTEM_CLOCK}] ${MODELPARAM_VALUE.SYSTEM_CLOCK}
}

proc update_MODELPARAM_VALUE.UART_BAUDRATE { MODELPARAM_VALUE.UART_BAUDRATE PARAM_VALUE.UART_BAUDRATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UART_BAUDRATE}] ${MODELPARAM_VALUE.UART_BAUDRATE}
}

proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.PARITY_ENABLE { MODELPARAM_VALUE.PARITY_ENABLE PARAM_VALUE.PARITY_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PARITY_ENABLE}] ${MODELPARAM_VALUE.PARITY_ENABLE}
}

proc update_MODELPARAM_VALUE.PARITY_ODD_EVEN { MODELPARAM_VALUE.PARITY_ODD_EVEN PARAM_VALUE.PARITY_ODD_EVEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PARITY_ODD_EVEN}] ${MODELPARAM_VALUE.PARITY_ODD_EVEN}
}

proc update_MODELPARAM_VALUE.STOP_BITS { MODELPARAM_VALUE.STOP_BITS PARAM_VALUE.STOP_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STOP_BITS}] ${MODELPARAM_VALUE.STOP_BITS}
}

