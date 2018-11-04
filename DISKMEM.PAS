{------------------------------------------------}
{                  Disk-Memory                   }
{                                                }
{              By Shiang Mei-Tien                }
{                                     1994/11/12 }
{------------------------------------------------}

{$IFDEF VMSVAR}
{$G}

Procedure FSeek(Block, Ofs: Word); Assembler;
Asm
        MOV       CX,Block
{       1 Blocks = 16384 bytes                }
{       Linear address = Block << 14 + Offset }
        XOR       DX,DX
        SHR       CX,1
        RCR       DX,1
        SHR       CX,1
        RCR       DX,1
        ADD       DX,Ofs
        ADC       CX,0
        MOV       AX,4200H
        MOV       BX,Handle
        INT       21H
End; { FSeek }

Function FRead(Var Buffer; Count: Word): Boolean; Assembler;
Asm
        MOV       AH,3FH
        MOV       BX,Handle
        MOV       CX,Count
        PUSH      DS
        LDS       DX,Buffer
        INT       21H
        POP       DS
        MOV       AL,0       { After DOS Int, If CF = 1, AX = error code }
        JC        @EXIT
        INC       AL         { Return TRUE if no error occured }
@EXIT:
End; { FRead }

Function FWrite(Var Buffer; Count: Word): Boolean; Assembler;
Asm
        MOV       AH,40H
        MOV       BX,Handle
        MOV       CX,Count
        PUSH      DS
        LDS       DX,Buffer
        INT       21H
        POP       DS
        MOV       AL,0       { After DOS Int, If CF = 1, AX = error code }
        JC        @EXIT
        INC       AL         { Return TRUE if no error occured }
@EXIT:
End; { FWrite }

Procedure FClose; Assembler;
Asm
        MOV       AH,3EH
        MOV       BX,Handle
        INT       21H
End; { FClose }

Function FGetFree(Drive: Byte): Word; Assembler;
Asm
        MOV       AH,36H
        MOV       DL,Drive
        INT       21H
{ Return:
        BX = Number of available clusrers
        DX = Number of clusters on drive
        CX = Number of bytes per sector
        If AX=0FFFFh, drive is invalid
        If AX<>0FFFFh, AX=number of sectors per cluster

        Free space in blocks = AX*BX*CX / 16384
}
        INC       AX
        JZ        @EXIT
        DEC       AX
        SUB       DX,DX
        MUL       CX
        MUL       BX
        SHL       AX,1
        RCL       DX,1
        SHL       AX,1
        RCL       DX,1
        XCHG      DX,AX
@EXIT:
End; { FGetFree }

Function FCreate(Name: String): Word; Assembler;
Asm
        PUSH      DS
        LDS       SI,Name    { Load pointer to Name }
        XOR       AX,AX
        LODSB                { Get string length }
        MOV       CX,AX
        JCXZ      @EXIT      { Zero length ? }
        MOV       DX,SI
        ADD       SI,CX
        MOV       [SI],CH    { Place a zero-byte at the end of string }
        MOV       CL,00100000B
        MOV       AH,3CH
        INT       21H
        JNC       @EXIT
        SUB       AX,AX
@EXIT:
        POP       DS
End; { FCreate }

Function FPut: Boolean; Assembler;
Asm
        MOV       CX,DeviceBlock
        XOR       DX,DX
        SHR       CX,1
        RCR       DX,1
        SHR       CX,1
        RCR       DX,1
        MOV       AX,4200H
        MOV       BX,Handle
        INT       21H
        MOV       AH,40H
        MOV       BX,Handle
        MOV       CX,BlockSize
        PUSH      DS
        LDS       DX,CacheBuffer
        INT       21H
        POP       DS
        MOV       AL,0
        JC        @EXIT
        INC       AL         { Return TRUE if no error occured }
@EXIT:
End; { FPut }

Function FGet: Boolean; Assembler;
Asm
        MOV       CX,DeviceBlock
        XOR       DX,DX
        SHR       CX,1
        RCR       DX,1
        SHR       CX,1
        RCR       DX,1
        MOV       AX,4200H
        MOV       BX,Handle
        INT       21H
        MOV       AH,3FH
        MOV       BX,Handle
        MOV       CX,BlockSize
        PUSH      DS
        LDS       DX,CacheBuffer
        INT       21H
        POP       DS
        MOV       AL,0
        JC        @EXIT
        INC       AL         { Return TRUE if no error occured }
@EXIT:
End; { FGet }

Procedure FQuit; Assembler;
Asm
@Dummy:
        PUSH      0
        PUSH      0
        CALL      FSeek
        PUSH      CS
        PUSH      Offset @Dummy
        PUSH      0
        CALL      FWrite
        CALL      FClose
@EXIT:
End; { FQuit }

Procedure FErase(Name: String); Assembler;
Asm
        PUSH      DS
        LDS       SI,Name    { Load pointer to Name }
        XOR       AX,AX
        LODSB                { Get string length }
        MOV       CX,AX
        JCXZ      @EXIT      { Zero length ? }
        MOV       DX,SI
        ADD       SI,CX
        MOV       [SI],CH    { Place a zero-byte at the end of string }
        MOV       AH,41H
        INT       21H
@Exit:
        POP       DS
End; { FErase }

Function InitDiskMemory(FName: String; Size: Word): Word;
Var
  Drive: Byte;
  Blocks: Word;
  Dummy: Byte;
Begin
  DiskMemReady := False;
  Drive := 0;
  SwapFile := FName;
  If (FName[2] = ':') Then
    Drive := Byte(FName[1]);
  Blocks := FGetFree(Drive);
  If (Blocks >= 4) Then
    Begin
      Handle := FCreate(FName);
      If (Handle = 0) Then
        Blocks := 0
      Else
        Begin
          If (Blocks > Size) Then Blocks := Size;
          FSeek(Blocks, 0);
          If Not FWrite(Dummy, 0) Then
            Begin
              FQuit;
              Blocks := 0;
            End
          Else
            DiskMemReady := True;
        End; { If Handle }
    End; { If Blocks }
  InitDiskMemory := Blocks;
End; { InitDiskMemory }

Procedure DoneDiskMemory; Assembler;
Asm
        CMP       DiskMemReady,True
        JNZ       @Exit
        CALL      FQuit
        PUSH      DS
        PUSH      OFFSET SwapFile
        CALL      FErase
        MOV       DiskMemReady,False
@Exit:
End; { DoneDiskMemory }

{$ENDIF}