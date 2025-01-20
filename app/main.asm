;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Kyle Stopplecamp, EELE 465, Project 1
; Jan 16 2025
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

init:
;-- Setup LED
		bis.b   #BIT0, &P1DIR	; Set P1.0 as an output. P1.0 is LED1
        bic.b	#BIT0, &P1OUT
        bis.b   #BIT6, &P6DIR
        bis.b	#BIT6, &P6OUT
		bic.b  	#LOCKLPM5, &PM5CTL0
;-- Setup Timer B0
		bis.w	#TBCLR, &TB0CTL
		bis.w	#TBSSEL__ACLK, &TB0CTL
		bis.w	#MC__UP, &TB0CTL
;-- Setup Compare Registers
		mov.w	#32900, &TB0CCR0
		bis.w	#CCIE, 	&TB0CCTL0
		bic.w	#CCIFG, &TB0CCTL0

		bis.w	#GIE, 	SR
main:
		xor.b	#BIT0, P1OUT 	; Toggle P1.0 (LED1)

        mov.w	#1000, R5		; Put number into R4 for desired #ms delay 
        add.w   #1, R5          ; Negates the first dec in time_delay
reset:
    	mov.w	#349, R4		; Put a number into R5 to make 1 ms
time_delay:
        dec.w	R5				; Decrement R5
		jnz  	milsec			; Repeat until R4 is 0
		jmp  	main			; Repeat main loop forever
milsec:
		dec.w	R4				; Decrement R4
		jnz  	milsec			; Repeat until R4 is 0
		jmp  	reset		    ; Repeat main loop forever
        NOP

;------------------------------------------------------------------------------
; Interrupt Service Routines
;------------------------------------------------------------------------------

ISR_TB0_CCR0:
		xor.b	#BIT6, &P6OUT
		bic.w	#CCIFG, &TB0CCTL0
		reti
                                            
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
            .sect 	".int43"
            .short	ISR_TB0_CCR0

