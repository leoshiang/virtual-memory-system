{------------------------------------------------}
{               Expanded-Memory                  }
{                                                }
{              By Shiang Mei-Tien                }
{                                     1994/11/12 }
{------------------------------------------------}

{$IFDEF VMSVAR }

Const
  EMSMemReady: Boolean = False;

Procedure EMSError;
Begin
  Halt(1);
End;

Procedure EMSGet(Block, Ofs: Word; Var Buffer; Count: Word); Assembler;
Asm
      { Save page map }
        MOV       AH,47H
        MOV       DX,EMSHandle
        INT       67H
        OR        AH,AH
        JZ        @EW1
        CALL      EMSError
@EW1:
      { Map/Unmap EMSHandle pages }
        MOV       AH,44H
        MOV       BX,Block
        INT       67H
        OR        AH,AH
        JZ        @EW2
        CALL      EMSError
@EW2:
      { Move data }
        PUSH      DS
        MOV       DS,EMSFrame
        MOV       SI,Ofs
        LES       DI,Buffer
        MOV       CX,Count
        CLD
        REP       MOVSB
        POP       DS
      { Restore page map }
        MOV       AH,48H
        MOV       DX,EMSHandle
        INT       67H
        OR        AH,AH
        JZ        @EW3
        CALL      EMSError
@EW3:
End; { EMSGet }

Procedure EMSPut(Block, Ofs: Word; Var Buffer; Count: Word); Assembler;
Asm
      { Save page map }
        MOV       AH,47H
        MOV       DX,EMSHandle
        INT       67H
        OR        AH,AH
        JZ        @EW1
        CALL      EMSError
@EW1:
      { Map/Unmap EMSHandle pages }
        MOV       AH,44H
        MOV       BX,Block
        INT       67H
        OR        AH,AH
        JZ        @EW2
        CALL      EMSError
@EW2:
      { Move data }
        PUSH      DS
        MOV       ES,EMSFrame
        MOV       DI,Ofs
        LDS       SI,Buffer
        MOV       CX,Count
        CLD
        REP       MOVSB
        POP       DS
      { Restore page map }
        MOV       AH,48H
        MOV       DX,EMSHandle
        INT       67H
        OR        AH,AH
        JZ        @EW3
        CALL      EMSError
@EW3:
End; { EMSPut }

Procedure GetEMSFrame; AssemBler;
Asm
      { Get page EMSFrame segment address }
        MOV       AH,41H
        INT       67H
        OR        AH,AH
        JZ        @EGF1
        CALL      EMSError
@EGF1:
        MOV       EMSFrame,BX
End; { GetEMSFrame }

Function InitExpandedMemory(Blocks: Word): Word; Assembler;
Asm
        CMP       Blocks,0
        JZ        @Error
        MOV       EMSMemReady,False
        MOV       AX,3567H
        INT       21H
        PUSH      DS
        MOV       DI,000AH
        PUSH      CS
        POP       DS
        LEA       SI,@DriverName
        XOR       AX,AX
        MOV       CX,8
        REP       CMPSB
        POP       DS
        JNZ       @Error
      { Get unallocated page count }
        MOV       AH,42H
        INT       67H
        OR        AH,AH
        JZ        @IEM1
        CALL      EMSError
@IEM1:
        OR        BX,BX
        JZ        @Exit
        MOV       AX,Blocks
        CMP       BX,AX
        JBE       @IEM2
        MOV       BX,AX
@IEM2:
        PUSH      BX
      { Allocate pages }
        MOV       AH,43H
        INT       67H
        OR        AH,AH
        POP       AX
        JZ        @IEM3
        CALL      EMSError
@IEM3:
        MOV       EMSHandle,DX
        MOV       EMSMemReady,True
        JMP       @Exit
@DriverName:
        DB        'EMMQXXX0'
@Error:
        SUB       AX,AX
@Exit:
End; { InitExpandedMemory }

Procedure DoneExpandedMemory; Assembler;
Asm
      { Deallocate pages }
        CMP       EMSMemReady,True
        JNZ       @Exit
        MOV       AH,45H
        MOV       DX,EMSHandle
        INT       67H
        OR        AH,AH
        JZ        @Exit
        CALL      EMSError
@Exit:
End; { DoneExpandedMemory }

{$ENDIF}
