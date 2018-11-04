Program TestVirtualArray;

Uses Crt;
{$G}
{$DEFINE NOEMS}
{$I VMS.PAS}
{$I VARRAY.PAS}

Var
  A: VArray;  { Virtual 2D array }
  W: Real;

Begin
  InitVirtualMemory(MaxBlocks);
  Writeln('Allocate ', Longint(MemAvail) shl 14, ' bytes of virutal memory');
  If InitArray2D(A, 1500, 1500, SizeOf(W)) Then
    Begin
      Writeln('Creating a 1500x1500 array of word');
      Writeln('Free memory is ', Longint(FreeMem) shl 14, ' bytes');
      W := 3.1415926;
      Writeln('Write ', W, ' to element [1500,1100]');
      PutArr2D(A, 1500, 1100, W);
      W := 0;
      Writeln('Read data from element [1500,1100]');
      GetArr2D(A, 1500, 1100, W);
      Writeln('The data is ', W);
    End;
  Writeln('Press any key to continue...');
  Readln;
  DoneVirtualMemory;
End.