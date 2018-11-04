{------------------------------------------------}
{             Virtual-memory  System             }
{                                                }
{              By Shiang Mei-Tien                }
{                                     1994/11/12 }
{------------------------------------------------}

{$I VMS_VAR.PAS}
{$I DISKMEM.PAS}
{$I EMSMEM.PAS}

Procedure InitVirtualMemory(Size: Word);
Var
  I, PoolPtr, DSKBlocks, EMSBlocks: Word;
Begin
  If VMSReady Then Exit;
  If (Size = 0) Then Exit;
  If (Size > MaxBlocks) Then Exit;
{$IFNDEF NOEMS}
  EMSBlocks := InitExpandedMemory(Size);
{$ELSE}
  EMSBlocks := 0;
{$ENDIF}

  PoolPtr := 0;
  If (EMSBlocks > 0) Then
    Begin
      Size := Size - EMSBlocks;
      While (PoolPtr < EMSBlocks) Do With Pool[PoolPtr] Do
        Begin
          Status := vm_EMS;
          BlockNo := PoolPtr;
          Inc(PoolPtr);
        End;
    End;
  DSKBlocks := 0;
  If (Size > 0) Then
    Begin
      DSKBlocks := InitDiskMemory('DISKMEM.SWP', Size);
      I := 0;
      While (I < DSKBlocks) Do With Pool[PoolPtr+I] Do
        Begin
          Status := vm_Dsk;
          BlockNo := I;
          Inc(I);
        End;
    End;
  GetMem(CacheBuffer, BlockSize);
  MemAvail := EMSBlocks + DSKBlocks;
  FreeMem := MemAvail;
  VMSReady := True;
End; { InitVirtualMemory }

Procedure DoneVirtualMemory; Assembler;
Asm
        CMP       VMSReady,True
        JNZ       @Exit
{$IFNDEF NOEMS}
        CALL      DoneExpandedMemory
{$ENDIF}
        CALL      DoneDiskMemory
        MOV       VMSReady,False
@Exit:
End; { DoneVirtualMemory }

Function GetFreeMem: Longint;
Begin
  GetFreeMem := Longint(FreeMem) * BlockSize;
End; { GetFreeMem }

Function AllocHeap(Var Heap: VHeap; Size: Longint): Boolean; Assembler;
Var
  Blocks: Word;
Asm
        SUB       AL,AL
        CMP       VMSReady,AL
        JZ        @Exit
        MOV       DX,WORD PTR Size
        MOV       AX,WORD PTR Size+2
        ADD       DX,BlockSize-1
        ADC       AX,0
        SHL       DX,1
        RCL       AX,1
        SHL       DX,1
        RCL       AX,1
        CMP       AX,FreeMem
        JBE       @NH1
        SUB       AL,AL
        JMP       @Exit
@NH1:
        SUB       FreeMem,AX
        LES       DI,Heap
        CLD
        STOSW
        MOV       CX,AX
        DEC       AX
        SHL       AX,1
        ADD       DI,AX
        MOV       SI,OFFSET Pool
        SUB       AX,AX
        MOV       DX,vm_Used
        STD
@NH2:
        TEST      [SI],DX
        JZ        @NH4
@NH3:
        INC       AX
        ADD       SI,4
        JMP       @NH2
@NH4:
        OR        [SI],DX
        MOV       AH,[SI+1]
        STOSW
        LOOP      @NH3
        MOV       BX,ES:[DI+2]
        AND       BX,3FFFH
        SHL       BX,2
        MOV       CX,WORD PTR Pool[BX]
        MOV       BX,WORD PTR Pool[BX+2]
        MOV       DeviceBlock,BX
        MOV       CachedBlock,0
        ROL       CX,3
        AND       CX,0003H
        MOV       CachedDevice,CX
        JCXZ      @NH_EMS
        CALL      FGet
        JMP       @NH5
@NH_EMS:
        CALL      EMSGet
@NH5:
        MOV       AL,1
@Exit:
End; { AllocHeap }

Procedure DisposeHeap(Var Heap: VHeap); Assembler;
Asm
        PUSH      DS
        MOV       DI,DS
        MOV       ES,DI
        MOV       DI,OFFSET Pool
        LDS       SI,Heap
        LODSW
        MOV       CX,AX
        PUSH      CX
        MOV       DX,7FFFH
@DH1:
        LODSW
        SHL       AX,2
        MOV       BX,DI
        ADD       DI,AX
        AND       ES:[DI],DX
        MOV       DI,BX
        LOOP      @DH1
        POP       CX
        POP       DS
        ADD       FreeMem,CX
End; { DisposeHeap }

Function ReadHeap(Var Heap: VHeap; Ofs: Longint;
                  Var Buffer; Count: Word): Boolean; Assembler;
Asm
        MOV       DX,WORD PTR Ofs
        MOV       AX,DX
        MOV       BX,WORD PTR Ofs+2
        SHL       DX,1
        RCL       BX,1
        SHL       DX,1
        RCL       BX,1       { BX = Block no }
        AND       AX,03FFFH  { AX = Offset }
        LES       DI,Heap
        CMP       BX,ES:[DI]
        JBE       @RH1
        SUB       AL,AL
        JMP       @Exit
@RH1:
        CMP       BX,CachedBlock
        JZ        @RH4
        PUSH      AX
        PUSH      BX
        MOV       CX,CachedDevice
        JCXZ      @RH_EMS
        CALL      FPut
        JMP       @RH2
@RH_EMS:
        CALL      EMSPut
@RH2:
        POP       BX
        MOV       CachedBlock,BX
        LES       DI,Heap
        INC       BX
        SHL       BX,1
        MOV       BX,ES:[DI+BX]
        MOV       CX,BX
        MOV       DX,3FFFH
        AND       BX,DX
        SHL       BX,2
        MOV       BX,WORD PTR Pool[BX+2]
        AND       BX,DX
        MOV       DeviceBlock,BX
        ROL       CX,3
        AND       CX,0003H
        MOV       CachedDevice,CX
        JCXZ      @RH2_EMS
        CALL      FGet
        JMP       @RH3
@RH2_EMS:
        CALL      EMSGet
@RH3:
        POP       AX
@RH4:
        PUSH      DS
        LDS       SI,CacheBuffer
        ADD       SI,AX
        LES       DI,Buffer
        MOV       CX,Count
        CLD
        REP       MOVSB
        POP       DS
        MOV       AL,1
@Exit:
End; { ReadHeap }

Function WriteHeap(Var Heap: VHeap; Ofs: Longint;
                  Var Buffer; Count: Word): Boolean; Assembler;
Asm
        MOV       DX,WORD PTR Ofs
        MOV       AX,DX
        MOV       BX,WORD PTR Ofs+2
        SHL       DX,1
        RCL       BX,1
        SHL       DX,1
        RCL       BX,1       { BX = Block no }
        AND       AX,03FFFH  { AX = Offset }
        LES       DI,Heap
        CMP       BX,ES:[DI]
        JBE       @RH1
        SUB       AL,AL
        JMP       @Exit
@RH1:
        CMP       BX,CachedBlock
        JZ        @RH4
        PUSH      AX
        PUSH      BX
        MOV       CX,CachedDevice
        JCXZ      @RH_EMS
        CALL      FPut
        JMP       @RH2
@RH_EMS:
        CALL      EMSPut
@RH2:
        POP       BX
        MOV       CachedBlock,BX
        LES       DI,Heap
        INC       BX
        SHL       BX,1
        MOV       BX,ES:[DI+BX]
        MOV       CX,BX
        MOV       DX,3FFFH
        AND       BX,DX
        SHL       BX,2
        MOV       BX,WORD PTR Pool[BX+2]
        AND       BX,DX
        MOV       DeviceBlock,BX
        ROL       CX,3
        AND       CX,0003H
        MOV       CachedDevice,CX
        JCXZ      @RH2_EMS
        CALL      FGet
        JMP       @RH3
@RH2_EMS:
        CALL      EMSGet
@RH3:
        POP       AX
@RH4:
        PUSH      DS
        LDS       SI,Buffer
        LES       DI,CacheBuffer
        ADD       DI,AX
        MOV       CX,Count
        CLD
        REP       MOVSB
        POP       DS
        MOV       AL,1
@Exit:
End; { WriteHeap }
