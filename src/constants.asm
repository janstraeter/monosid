#importonce

.label INTERRUPT_VECTOR_LO 			= $0314
.label INTERRUPT_VECTOR_HI 			= $0315
.label SCREENMEM					= $0400

.namespace ZEROPAGE {
	.label LAST_PRESSED_KEY			= $C5
	.label CURRENT_PRESSED_KEY		= $CB
	.label TEMP_1					= $FB
	.label TEMP_1_LO				= $FB
	.label TEMP_1_HI				= $FC
	.label TEMP_2					= $FD
	.label TEMP_2_LO				= $FD
	.label TEMP_2_HI				= $FE
}

.namespace CIA {
	.label INTERRUPT_CONTROL_STATE 	= $dc0d
}

.namespace VIC {
	.label CONTROL_REGISTER_1 		= $d011
	.label RASTER_COUNTER			= $d012
	.label INTERRUPT_REGISTER		= $d019
	.label INTERRUPT_ENABLED		= $d01a
	.label BORDERCOLOR				= $d020
	.label BACKGROUND_COLOR_0		= $d021
}

.namespace KERNAL {
	.label TEXTCOLOR				= $0286
	.label CLS						= $e544
	.label INTERRUPT_ROUTINE		= $ea31
	.label CHRIN					= $ffe4
}
