{---------------------------------------------------------}
{                       TESTVMEM.PAS                      }
{ Author: M.T. Shiang                                     }
{                                                         }
{ Date: 1994/11/20                                        }
{                                                         }
{ File Name: TESTVMEM.PAS                                 }
{                                                         }
{ Purpose: Test for VMS.PAS, VARRAY.PAS                   }
{---------------------------------------------------------}

Program TestVMEM;

Uses Crt;

{$DEFINE NOEMS}
{$I VMS.PAS}
{$I VARRAY.PAS}

{ Define some data type fo test}
Type
  Def1 = Record
    X, Y, Z: Double;
  End;

  Def2 = Record
    S: String[80];
    I: Integer;
    L: Longint;
    D: Double;
  End;

  Def3 = Record
    D1: Double;
    D2: Double;
  End;

Var
  Def: Def3;
  A: VArray;
  H: VHeap;

{---------------------------------------------------------}
{                       Main program                      }
{---------------------------------------------------------}
Begin
  ClrScr;
  InitVirtualMemory(MaxBlocks);
  { Display the status of virtual-memory }
  Writeln('Size of virtual-memory: ', GetFreeMem, ' bytes');

  { Allocate virutal heap H and test it's size }
  Writeln('Allocate 6214 bytes for heap H...');
  AllocHeap(H, 6214);
  Writeln('Ok!');
  Writeln('Free memory is ', GetFreeMem, ' bytes');

  DoneVirtualMemory;
End.

