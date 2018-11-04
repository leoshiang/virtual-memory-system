{------------------------------------------------}
{                Virtual-Array                   }
{                                                }
{              By Shiang Mei-Tien                }
{                                     1994/11/12 }
{------------------------------------------------}

Type
  VArray = Record
    Heap: VHeap;
    RecLen: Word;
    DimX: Longint;
  End;

Function InitArray1D(Var A: VArray; Size: Longint;
                     ElementSize: Word): Boolean; Assembler;
Asm
        LES       DI,A
        MOV       AX,ElementSize
        MOV       VArray(ES:[DI]).RecLen,AX
        PUSH      ES
        PUSH      DI
DB 66H; SUB       AX,AX
DB 66H; SUB       DX,DX
        MOV       AX,VArray(ES:[DI]).RecLen
DB 66H; MOV       CX,WORD PTR Size
DB 66H; MUL       CX
DB 66H; PUSH      AX
        CALL      AllocHeap
End; { InitArray1D }

Procedure PutArr1D(Var A: VArray; Pos: Longint; Var Buffer); Assembler;
Asm
        LES       DI,A
        PUSH      ES
        PUSH      DI
DB 66H; SUB       AX,AX
DB 66H; SUB       DX,DX
        MOV       AX,VArray(ES:[DI]).RecLen
DB 66H; MOV       CX,WORD PTR Pos
DB 66H; MUL       CX
DB 66H; PUSH      AX
        PUSH      WORD PTR Buffer+2
        PUSH      WORD PTR Buffer
        PUSH      VArray(ES:[DI]).RecLen
        CALL      WriteHeap
End; { PutArr1D }

Procedure GetArr1D(Var A: VArray; Pos: Longint; Var Buffer); Assembler;
Asm
        LES       DI,A
        PUSH      ES
        PUSH      DI
DB 66H; SUB       AX,AX
DB 66H; SUB       DX,DX
        MOV       AX,VArray(ES:[DI]).RecLen
DB 66H; MOV       CX,WORD PTR Pos
DB 66H; MUL       CX
DB 66H; PUSH      AX
        PUSH      WORD PTR Buffer+2
        PUSH      WORD PTR Buffer
        PUSH      VArray(ES:[DI]).RecLen
        CALL      ReadHeap
End; { GetArr1D }

Function InitArray2D(Var A: VArray; XDim, YDim: Longint;
                     ElementSize: Word): Boolean; Assembler;
Asm
        LES       DI,A
        MOV       AX,ElementSize
        MOV       VArray(ES:[DI]).RecLen,AX
DB 66H; MOV       AX,WORD PTR XDim
DB 66H; MOV       WORD PTR VArray(ES:[DI]).DimX,AX
        PUSH      ES
        PUSH      DI
DB 66H; SUB       AX,AX
DB 66H; SUB       DX,DX
        MOV       AX,VArray(ES:[DI]).RecLen
DB 66H; MOV       CX,WORD PTR XDim
DB 66H; MUL       CX
DB 66H; MOV       CX,WORD PTR YDim
DB 66H; MUL       CX
DB 66H; PUSH      AX
        CALL      AllocHeap
End; { InitArray2D }

Procedure PutArr2D(Var A: VArray; X, Y: Longint; Var Buffer); Assembler;
Asm
        LES       DI,A
        PUSH      ES
        PUSH      DI
DB 66H; SUB       AX,AX
DB 66H; SUB       DX,DX
DB 66H; MOV       AX,WORD PTR VArray(ES:[DI]).DimX
DB 66H; MOV       CX,WORD PTR Y
DB 66H; MUL       CX
DB 66H; ADD       AX,WORD PTR X
        MOV       CX,VArray(ES:[DI]).RecLen
        MUL       CX
DB 66H; PUSH      AX
        PUSH      WORD PTR Buffer+2
        PUSH      WORD PTR Buffer
        PUSH      VArray(ES:[DI]).RecLen
        CALL      WriteHeap
End; { PutArr2D }

Procedure GetArr2D(Var A: VArray; X, Y: Longint; Var Buffer); Assembler;
Asm
        LES       DI,A
        PUSH      ES
        PUSH      DI
DB 66H; SUB       AX,AX
DB 66H; SUB       DX,DX
DB 66H; MOV       AX,WORD PTR VArray(ES:[DI]).DimX
DB 66H; MOV       CX,WORD PTR Y
DB 66H; MUL       CX
DB 66H; ADD       AX,WORD PTR X
        MOV       CX,VArray(ES:[DI]).RecLen
        MUL       CX
DB 66H; PUSH      AX
        PUSH      WORD PTR Buffer+2
        PUSH      WORD PTR Buffer
        PUSH      VArray(ES:[DI]).RecLen
        CALL      ReadHeap
End; { GetArr2D }
