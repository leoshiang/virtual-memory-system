{$DEFINE VMSVAR}

{ Varaiables for DISKMEM.PAS }

Var
  Handle: Word;
  SwapFile: String;
  DiskMemReady: Boolean;

{ Varaiables for EMSMEM.PAS }

Var
  EMSHandle: Word;
  EMSFrame: Word;

{ Varaiables for VMS.PAS }

Const
  MaxBlocks   = 1024;
  BlockSize   = 16384;
  EMSReserved = 2;
  vm_EMS  = $2000;
  vm_Dsk  = $4000;
  vm_Used = $8000;

Type
  BlockInfo = Record
    Status: Word;
    BlockNo: Word;
  End;

  BlockArrayPtr = ^BlockArray;
  BlockArray = Array[0..MaxBlocks-1] Of BlockInfo;

  VHeap = Record
    BlockCount: Word;
    Blocks: Array[0..MaxBlocks-1] Of Word;
  End;

Var
  Pool: BlockArray;
  MemAvail: Word;
  FreeMem: Word;
  CacheBuffer: Pointer;
  CachedBlock: Word;
  DeviceBlock: Word;
  CachedDevice: Word;

Const
  VMSReady: Boolean = False;
