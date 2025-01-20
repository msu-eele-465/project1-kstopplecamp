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
		bic.w	#BIT0, PM5CTL0  ; Disable the GPIO power-on default high-Z mode
		bis.b   #BIT0, P1DIR		; SEt P1.0 as an output. P1.0 is LED1
main:
		xor.b	#01h, P1OUT 	; Toggle P1.0 (LED1)

        mov.w	#1000, R5		    ; Put number into R4 for desired #ms delay 
        add.w   #1, R5          ; Negates the first dec in time_delay
reset:
    	mov.w	#348, R4		; Put a number into R5 to make 1 ms
time_delay:
        dec.w	R5				; Decrement R5
		jnz  	milsec			; Repeat until R4 is 0
		jmp  	main			; Repeat main loop forever
milsec:
		dec.w	R4				; Decrement R4
		jnz  	milsec			; Repeat until R4 is 0
		jmp  	reset		    ; Repeat main loop forever
        NOP


                                            
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
            
