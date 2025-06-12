; =============================================================================
; noclick.S
; islandcontroller/amiga-noclick
;
; This utility changes the disk presence checking to a "silent" method.
; Do not use this utility if it causes the drive to behave unexpectedly!
;
; Usage: run this program from a shell.
;
; SPDX-License-Identifier: MIT
; See LICENSE file for full license text.
;
; This utility is inspired by Patrik Axelsson's "NoClick", and was rewritten
; in assembly from scratch using Asm-Pro V1.21.
; =============================================================================

; Macros ----------------------------------------------------------------------
; exec library base address (fixed)
EXECBASE	EQU	4

; FUNCDEF macro req'd before exec_lib include
FUNC_CNT	SET	-30 ; LIB_USERDEF
FUNCDEF		MACRO
_LVO\1		EQU	FUNC_CNT
FUNC_CNT	SET	FUNC_CNT-6
		ENDM


; Includes --------------------------------------------------------------------
		INCDIR	"AsmPro:include/"
		INCLUDE	"exec/exec_lib.i"
		INCLUDE	"exec/libraries.i"
		INCLUDE	"devices/trackdisk.i"


; Entry point -----------------------------------------------------------------
		JUMPPTR	_entry
_entry:
		; Global setup. EXECBASE in a6
		move.l	EXECBASE,a6	

		; Create new message port. Returns ptr in d0
		jsr	_LVOCreateMsgPort(a6)
		tst.l	d0
		bne	.GotPort
		moveq	#20,d0
		rts
.GotPort:
		move.l	d0,pDiskPort

SetDriveUnits:
		; Loop over all drive units (d2=unit index)
		moveq	#(NUMUNITS-1),d2
.Loop:
		; Create new IO request (d0=port, d1=size). Resulting ptr
		; in d0
		move.l	pDiskPort,a0
		moveq	#IOTD_SIZE,d0
		jsr	_LVOCreateIORequest(a6)
		tst	d0
		beq	.Continue ; skip to next unit on error
		move.l	d0,pIoReq

		; Try to open the device (a0=name, d0=unit num, a1=ioreq,
		; d1=flags). Returns error code in d0 (nonzero if failed)
		; and places device node in a1
		move.l	d0,a1
		move.l	#szDevName,a0
		move.l	d2,d0
		clr	d1
		jsr	_LVOOpenDevice(a6)
		tst	d0
		bne	.DelReq ; skip to cleanup on error

		; Set NOCLICK flag in unit flags field
		move.l	IO_UNIT(a1),a2
		ori.b	#TDPF_NOCLICK,TDU_PUBFLAGS(a2)

		; Close device (a1=deviceNode)
		jsr	_LVOCloseDevice(a6)
.DelReq:
		; Delete IO request (a0=req)
		move.l	pIoReq,a0
		jsr	_LVODeleteIORequest(a6)
.Continue
		dbne	d2,.Loop
		
Cleanup:
		; Delete message port (a0=port)
		move.l	pDiskPort,a0
		jsr	_LVODeleteMsgPort(a6)

		moveq	#0,d0
		rts


; Global data -----------------------------------------------------------------
		SECTION	.data,CODE
		EVEN
szDevName	DC.B	"trackdisk.device",0 ; Device driver name

		SECTION	.bss,BSS
		EVEN
pDiskPort	DS.L	1 ; Message port for trackdisk device
pIoReq		DS.L	1 ; IO request for trackdisk port
