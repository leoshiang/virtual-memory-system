(**********************************************************)
(*                      VMEM.PAS                          *)
(*                                                        *)
(*  Author   : M.T.Shiang                                 *)
(*                                                        *)
(*  Date     : 1994/11/21                                 *)
(*                                                        *)
(*  File name: VMEM.PAS                                   *)
(*                                                        *)
(*  Purpose  : Unit for the management of "VHEAP".        *)
(*                                                        *)
(*  Reference: VDEVICE                                    *)
(**********************************************************)

Unit VMEM;

Interface

(*
Uses VDEVICE;  { This unit employes some routines in unit "VDEVICE"}
*)

Const
  VMEMBlocks = 1024;    { The maximum size of one heap is 16M bytes }
                        { 1024 blocks * 16kb/block = 16M }
  VMEMHandles = 1024;   { Maximum number of handles }

Type
  { Status of VHeap }
  VMEMStatus = (Ok, NotInit, NotEnoughMem, OutOfMem,
                VMEM_InvalidInit);

  { Type of device that VDEVICE uses }
  DeviceType = (Exp,         { Expanded memory }
                Dsk);        { Disk file }

  { Definition of virtual-heap }
  VHeapPtr = ^VHeap;                             { Pointer to VHeap }
  VHeap = Record
    ID: Word;                                    { Identifier code }
    Blocks: Array[1..VMEMBlocks] Of Word;        { VHeap control array }
    BlockCount: Integer;                         { Number of blocks }
  End;

{ Global variables  }
Const
  VMEMInit: Boolean = False; { VMEMInit = True, if system initialized }
                             { VMEMInit = False, if system not initialized }

Var
  PoolSize: Word;            { Size of memory pool in blocks }
  FileName: String;          { File name of disk file }
  FileHanle: Word;           { Handle of disk file }
  FileSize: Word;            { Size of disk memory in blocks }

Implementation

(************************************************************************)
(* Function: Install VEMM system                                        *)
(*                                                                      *)
(* Input: Size:Word;    Size of memory pool in blocks                   *)
(*                                                                      *)
(* Return: The status of VMEM system (success, or error code)           *)
(*                                                                      *)
(* External: Name                   Source                              *)
(*           Writeln                Run-Time Library                    *)
(************************************************************************)
Function InitVMEM(Size: Word): VMemStatus;
Begin
  { If VMEM system is already initialized or the size of memory pool }
  { equals zero, then return VMEM_InvalidInit }
  If (VMEMInit) Or (Size = 0) Then
    Begin
      InitVMEM := VMEM_InvalidInit;
      Exit;
    End;

  BlockUsed := 0;




(************************************************************************)
(* Function: Transfer data from dos heap to Virtual-Heap                *)
(*                                                                      *)
(* Input:                                                               *)
(*         Var Heap: VHeap;  Virtual-Heap                               *)
(*         Var Data;         Address of data that will be transfered    *)
(*         Count: Longint;   Number of bytes to transfer                *)
(*         Dest: Longint;    Destination of virtual-memory              *)
(*                                                                      *)
(* Output:                                                              *)
(*         Status of VMEM                                               *)
(*                                                                      *)
(* External:                                                            *)
(*                                                                      *)
(************************************************************************)
Function WriteVHeap(Var Heap: VHeap;
                    Var Data;
                    Count: Longint;
                    Dest: Longint): VMemStatus;
Var
  Block: Word;
  Offset: Word;
Begin
  { Convert linear address into the form of Block:Offset }
  Block := Dest SHR 14;
  Offset := Dest - Block SHL 14;

  { If "Block" is great than the total number of blocks in "Heap" }
  { ,we must
  If (Block > Heap.BlockCount) Then
    Begin
      WriteHeap := VMEM_Invalid;
      Exit;
    End;



{*----------------------------------------------------------------------------*{
{* 功能 ： 安裝 POWRSTOR 系統                                                 *{
{*                                                                            *{
{* 參數 ： unsigned          NeededSize :  memory pool 的大小 (block 個數)    *{
{*         union INITelement *initArray :  設定 memory pool 所需的「初始陣列」*{
{*         int               infoflag   :  是否要輸出資訊檔.                  *{
{*                                         0  表示不要                        *{
{*                                         1  表示要                          *{
{*                                                                            *{
{* 迴返值 ： POWRSTOR 狀態 (成功，或錯誤代碼)                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              printf()                C  Run Time 程式庫                    *{
{*              getch()                 C  Run Time 程式庫                    *{
{*              sprintf()               C  Run Time 程式庫                    *{
{*                                                                            *{
{*              EXPsize()               POWRDEVC    程式庫                    *{
{*              EXPframe()              POWRDEVC    程式庫                    *{
{*              EXTsize()               POWRDEVC    程式庫                    *{
{*              filSize()               POWRDEVC    程式庫                    *{
{*              shellinfo2file()        POWRDEVC    程式庫                    *{
{*                                                                            *{
{*              QuitPwr()               POWRSTOR    程式庫                    *{
{*              Blocks_status_display() POWRSTOR    程式庫                    *{
{*----------------------------------------------------------------------------*{
STORstatus InitPwr( unsigned          NeededSize,
                    union INITelement *initArray,
                    int               infoflag
                  )
{
unsigned    i,j, ib;         {* Blocks[] 陣列的指標 (index) *{
char        msg[80];         {* 傳給資訊檔的訊息            *{
unsigned    DiskNeededSize;  {* 磁碟記憶體的需求量          *{
STORstatus  stat;            {* POWRSTOR 狀態               *{


    {*  如果 POWRSTOR 已經安裝，傳回 InvalInit 代碼 *{
    if( pwrInitialized ) return InvalInit;

    {*  如果要求的 memory pool 大小是零，傳回 InvalInit 代碼 *{
    if( NeededSize == 0 ) return InvalInit;

    {*  如果要求的 memory pool 大於 POWRSTOR 的能力，傳回 InvalInit 代碼 *{
    if( NeededSize > VMEMBLOCKS ) return InvalInit;


    {* 檢查設定 memory pool時所需的「初始陣列」，內容是否都是合法的設定 *{
    i = 0;
    while( i < 16 )   {* 「初始陣列」的大小是 16 *{
        switch( initArray[i].Nulmem.memType )    {* 檢驗其記憶體設定型態 *{
        {
            {* 如果是延伸，或擴展，或磁碟記憶體，則 i 值累加 1 *{
            case ExpMem  :
            case ExtMem  :
            case DskFile :
                           i += 1;
                           break;

            case NulMem  : {* 結束標記 *{
                           if ( i > 0 ) i = 17;
                           else         i = 18;
                           break;

            default      : i = 65535;
                           break;
        }

    if( i == 16 )      {* 「初始陣列」的元素太多 *{
       return BadInitData;

    if( i == 65535 )   {* 「初始陣列」中有不合法的記憶體型態設定 *{
       return BadInitData;

    if( i == 18 )      {* 「初始陣列」的元素太少 *{
       return InvalInit;

    stat = Okay;       {* 初始陣列的內容合於規定 *{



    #if (STORDEBUG)         {* 除錯階段, 列印出各項資料內容 *{
    Blocks_status_display();
    #endif



    i = 0;
    ib = 0;                  {* 「POWRSTOR 管理陣列」的指標 (index) 設定在起頭 *{
    blksUsed = 0;            {* 「POWRSTOR 管理陣列」中被使用的 block 個數     *{
    POOLsize = NeededSize ;  {* memory pool 的實際大小應等於吾人需求的輔助記憶體大小 *{

    while( (initArray[i].Nulmem.memType != NulMem) &&  {*    針對每一個「初始陣列」元素 *{
           (NeededSize > 0) &&                         {* 且 memory pool 大於零         *{
           (stat == Okay)      )                       {* 且 合法的「初始陣列」         *{
    {
        switch( initArray[i].Nulmem.memType )  {  {* 針對不同的記憶體型態 *{

            case ExpMem  : {* 擴展記憶體 *{

                 {* 配置擴展記憶體 *{
                 EXPsize(initArray[i].EXPmem.Rsrvd, NeededSize,\
                         &ExpHandle, &ExpSize);

                 if (ExpSize == 0)       {* 沒有配置到擴展記憶體 *{
                     break;

                 ExpFrame = EXPframe();  {* 求擴展記憶體的頁框位址 *{

                 ExpFlag = ib;  {* ExpFlag 設定為指向「POWRSTOR 管理陣列」中擴展記憶體的起始處 *{


                 #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
                 printf("initArray[%d]: ExpMem. Rsrvd = %u  NeededSize = %u \n", \
                         i, initArray[i].EXPmem.Rsrvd, NeededSize );
                 printf("               ExpHandle = %u  ExpFrame = \%x   ExpSize = %u  ExpFlag = %u \n",
                         ExpHandle, ExpFrame, ExpSize, ExpFlag );
                 #endif


                 for(j=ib; j< ib+ExpSize ; j++)  {* 將這些擴展記憶體記錄於「POWRSTOR 管理陣列」中 *{
                     Blocks[j].type = EXP_TYPE;

                 ib += ExpSize;          {* 修正「POWRSTOR 管理陣列」的指標   *{
                 NeededSize -= ExpSize;  {* 修正尚需配置的輔助記憶體 block 數 *{

                 #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
                 printf("NeededSize = %u \n", NeededSize );
                 getch() ;
                 #endif

                 break;

            case ExtMem  :  {* 延伸記憶體 *{

                 ExtSize = EXTsize();  {* 偵測延伸記憶體的大小，單位為 K *{

                 {* 計算延伸記憶體基底位址 (單位不是 K，請注意) *{
                 ExtBase = (initArray[i].EXTmem.LoLimit << 6);

                 ExtFlag = ib;  {* ExpFlag 設定為指向「POWRSTOR 管理陣列」中延伸記憶體的起始處 *{


                 #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
                 printf("initArray[%d]: NeededSize = %u  ExtLoLimit = %u  ExtHiLimit = %u \n", \
                         i, NeededSize, initArray[i].EXTmem.LoLimit, initArray[i].EXTmem.HiLimit );
                 printf("               ExtSize = %u  ExtFlag = %u  ExtBase = %u  \n",
                         ExtSize, ExtFlag, ExtBase );
                 #endif


                 ExtSize >>= 4 ;  {* 將延伸記憶體的大小由 K 轉換為 blocks *{

                 if (initArray[i].EXTmem.LoLimit >= 64) {
                     if (initArray[i].EXTmem.HiLimit == 0) {
                         {* 表示將運用所有的延伸記憶體 *{
                         ExtSize = (ExtSize >= NeededSize) ? NeededSize : ExtSize ;
                     }
                     else if ((initArray[i].EXTmem.HiLimit - initArray[i].EXTmem.LoLimit + 1) >= 4)  {
                         {* 表示僅運用一部份的延伸記憶體 *{
                         ExtSize = (initArray[i].EXTmem.HiLimit - initArray[i].EXTmem.LoLimit + 1);
                         ExtSize = (ExtSize >= NeededSize) ? NeededSize : ExtSize ;
                     }
                     else {  {* 不運用延伸記憶體於 memory pool 中 *{
                         ExtSize = 0;
                     }
                 }
                 else { {* EXTmem.LoLimit < 64. 亦即不運用延伸記憶體 *{
                     ExtSize = 0;
                 }


                 for(j=ib; j< ib+ExtSize; j++)  {* 將這些延伸記憶體記錄於「POWRSTOR 管理陣列」中 *{
                     Blocks[j].type = EXT_TYPE;

                 ib += ExtSize;          {* 修正「POWRSTOR 管理陣列」的指標   *{
                 NeededSize -= ExtSize;  {* 修正尚需配置的輔助記憶體 block 數 *{

                 #if (STORDEBUG) {* 除錯階段, 列印出各項資料內容 *{
                 printf("NeededSize = %u \n", NeededSize );
                 getch() ;
                 #endif

                 break;

            case DskFile :  {* 磁碟記憶體 *{

                 {* 計算應該索求多少磁碟空間 *{
                 {* 若需求量大於設定的最大允許量，就用最大允許量 *{
                 if ( NeededSize > initArray[i].diskF.MaxSize )
                      DiskNeededSize = initArray[i].diskF.MaxSize;
                 else
                      DiskNeededSize = NeededSize;

                 {* 配置磁碟空間 *{
                 FileSize = filSize(initArray[i].diskF.namestring, \
                                    &FileHandle, DiskNeededSize) ;

                 FileFlag = ib;  {* ExpFlag 設定為指向「POWRSTOR 管理陣列」中磁碟記憶體的起始處 *{


                 #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
                 printf("initArray[%d]: NeededSize = %u  MaxSize = %u  namestring = %s \n", \
                         i, NeededSize, initArray[i].diskF.MaxSize, initArray[i].diskF.namestring );
                 printf("               FileSize = %u  DiskNeededSize = %u \n", FileSize, DiskNeededSize );
                 #endif



                 for(j=ib; j< ib+FileSize; j++)  {* 將這些磁碟記憶體記錄於「POWRSTOR 管理陣列」中 *{
                     Blocks[j].type = DSK_TYPE;


                 ib += FileSize;          {* 修正「POWRSTOR 管理陣列」的指標   *{
                 NeededSize -= FileSize;  {* 修正尚需配置的輔助記憶體 block 數 *{

                 #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
                 printf("NeededSize = %u \n", NeededSize );
                 getch() ;
                 #endif

                 break;
        }   {* switch() *{

        i++ ;   {* 修正「初始陣列」的指標，以便能夠進行下一個配置動作 *{

        if (NeededSize == 0)    {* 記憶體已配置足夠，不需再進行下去 *{
        break;
    }


    stat = Okay;  {* 設定狀態，表示輔助記憶體硬體裝置配置成功 *{


    if( (stat != Okay) ||         {*   安裝 memory pool 不成功，        *{
        (NeededSize > 0) )        {* 或輔助記憶體不能夠滿足需求量       *{
    {
        QuitPwr();                {* 離開 POWRSTOR 系統，釋放所有記憶體 *{
        if( stat == Okay )
           stat = NotEnoughMem;   {* 設定 POWRSTOR 的狀態代碼           *{
        return stat;              {* 傳回狀態值給呼叫函數               *{
    }


    {* 輸出資訊檔案 *{
    if (infoflag == 1) {
        sprintf(msg,"POWRSTOR installed !!\n");
        shellinfo2file(msg);    {* 傳送訊息至資訊檔 *{
        sprintf(msg,"POWRSTOR use total     %4u Blocks, %8u K \n",POOLsize,POOLsize*16);
        shellinfo2file(msg);    {* 傳送訊息至資訊檔 *{
        sprintf(msg,"         Ext used :   %4u Blocks, %8u K \n",ExtSize,ExtSize*16);
        shellinfo2file(msg);    {* 傳送訊息至資訊檔 *{
        if (ExtSize != 0)  {
            sprintf(msg,"             Base :   %4u  \n",ExtBase);
            shellinfo2file(msg);    {* 傳送訊息至資訊檔 *{
        }
        sprintf(msg,"         Exp used :   %4u Blocks, %8u K \n",ExpSize,ExpSize*16);
        shellinfo2file(msg);    {* 傳送訊息至資訊檔 *{
        sprintf(msg,"         Dsk used :   %4u Blocks, %8u K \n",FileSize,FileSize*16);
        shellinfo2file(msg);    {* 傳送訊息至資訊檔 *{
    }




    #if (STORDEBUG)   {* 除錯階段, 列印出各項資料內容 *{
    Blocks_status_display();
    #endif

    pwrInitialized = true;  {* 設定「安裝旗標」，表示 POWRSTOR 已安裝完成 *{

    return Okay;            {* 完全成功，回返值為 Okay *{

}
{*----------------------------------------------------------------------------*{
{* 功能 ：  離開 POWRSTOR 系統                                                *{
{*          所有曾經被配置的輔助記憶體均將在此函數中釋放                      *{
{*                                                                            *{
{* 參數 ：  無                                                                *{
{*                                                                            *{
{* 迴返值 ： 無                                                               *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              EXTquit()               POWRDEVC  程式庫                      *{
{*              EXPquit()               POWRDEVC  程式庫                      *{
{*              filQuit()               POWRDEVC  程式庫                      *{
{*----------------------------------------------------------------------------*{
void QuitPwr(void)
{
    unsigned i;

    if( pwrInitialized )            {* POWRSTOR 已經安裝 *{
    {
        if (ExpFlag != 65535)       {* memory pool 中有擴展記憶體 *{
            EXPquit( ExpHandle ) ;  {* 釋放擴展記憶體             *{

        if (ExtFlag != 65535)       {* memory pool 中有延伸記憶體 *{
            EXTquit( ) ;            {* 釋放延伸記憶體             *{

        if (FileFlag != 65535)      {* memory pool 中有磁碟記憶體 *{
            filQuit( FileHandle ) ; {* 釋放磁碟記憶體             *{

        pwrInitialized = false;     {* 設定安裝旗標為零           *{
    }

}
{*----------------------------------------------------------------------------*{
{* 功能 ： 偵測 memory pool 中已被使用的空間大小                              *{
{*                                                                            *{
{* 參數 ： unsigned long  *bytesUsed  :  此參數將傳回已使用之空間 (bytes)     *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              無                                                            *{
{*                                                                            *{
{* 注意 ：  由於 POWRSTOR 是以 block 為單位，所以 *bytesUsed 必將是           *{
{*          16384 (16K) 的整數倍                                              *{
{*----------------------------------------------------------------------------*{
STORstatus STORused( unsigned long  *bytesUsed )
{
    if( pwrInitialized == false )    {* POWRSTOR 尚未安裝 *{
        return NotInitialized;

    *bytesUsed = blksUsed;  {* memory pool 中被使用的 block 個數 *{

    *bytesUsed <<= 14;      {* 把 block 轉換為 bytes *{

    return Okay;
}
{*----------------------------------------------------------------------------*{
{* 功能 ：  偵測 memory pool 中剩餘的可用空間                                 *{
{*                                                                            *{
{* 參數 ：  unsigned long  *bytesAvailable  : 此參數將傳回可用空間 (bytes)    *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              無                                                            *{
{*                                                                            *{
{* 注意 ：  由於 POWRSTOR 是以 block 為單位，所以 *bytesAvailable 必將是      *{
{*          16384 (16K) 的整數倍                                              *{
{*----------------------------------------------------------------------------*{
STORstatus STORavai( unsigned long  *bytesAvailable )
{
    if( pwrInitialized == false )   {* POWRSTOR 尚未安裝 *{
        return NotInitialized;

    *bytesAvailable = POOLsize-blksUsed;  {* memory pool 中剩餘的可用 block 個數 *{

    *bytesAvailable <<= 14;    {* 把 block 轉換為 bytes *{

    return Okay;
}
{*----------------------------------------------------------------------------*{
{* 功能 ：  產生一個 STORheap，大小為零                                       *{
{*                                                                            *{
{* 參數 ：  struct STORheap  *heapID : 此參數指向 STORheap 的資料結構，       *{
{*                                     將傳回 STORheap 的所有資訊。           *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              無                                                            *{
{*----------------------------------------------------------------------------*{
STORstatus newSheap( struct STORheap  *heapID )
{
int i;

    if( pwrInitialized == false ) {* POWRSTOR 尚未安裝 *{
        return NotInitialized;


    {* 首先將變數清乾淨 *{
    heapID->actblocks = 0;
    for (i=0 ; i< STORheapBLOCKS; i++)
         heapID->blocks[i] = 0;


    {* 配置 STORheap 的識別碼 *{
    heapID->ID = curID;


    curID ++ ;   {* 累計識別碼 *{


    return Okay;
}
{*----------------------------------------------------------------------------*{
{* 功能 ：   設定 STORheap 的空間大小                                         *{
{*                                                                            *{
{* 參數 ：   struct STORheap  *heapID :  STORheap 的資料結構                  *{
{*           unsigned long    newSize :  STORheap 的空間大小 (bytes)          *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                                  來源                    *{
{*              Blocks_status_display();              POWRSTOR  程式庫        *{
{*              heapID_status_display(*heapID);       POWRSTOR  程式庫        *{
{*----------------------------------------------------------------------------*{
STORstatus  setSheap( struct STORheap  *heapID,
                      unsigned long    newSize
                    )
{
int        counter = 0;
unsigned   i;
int        enoughflag = false;


    if( pwrInitialized == false ) {* POWRSTOR 尚未安裝 *{
        return NotInitialized;


    {* 把 bytes 轉換為 blocks *{
    heapID->actblocks = (newSize >> 14) + 1;   {* 可能會浪費一個 blocks *{


    {* memory pool 是否有足夠的空間 ? *{
    for(i=0, counter=0; i< VMEMBLOCKS; i++) {
        if ( Blocks[i].flag.used == 0 )   {   {* 此 block 尚未被使用   *{
             counter ++ ;                     {* 可用的 block 個數加 1 *{
        }

        if (counter == heapID->actblocks) {   {* 足夠的空間 *{
            enoughflag = true;
            break;
        }
    }


    if (! enoughflag)   {* memory pool 的空間不足 *{
        return NotEnoughMem;

    {* 配置 memory pool 的記憶體空間到 STORheap 中 *{
    for(i=0,counter=0; i< VMEMBLOCKS; i++) {
        if ( Blocks[i].flag.used == 0 )   {    {* 此 block 尚未被使用        *{
             heapID->blocks[ counter ] = i;    {* 記錄到 STORheap 管理陣列中 *{
             counter ++ ;                      {* 累計已配置的 block 個數    *{
             Blocks[i].flag.ID = heapID->ID ;  {* 記錄識別碼                 *{
             Blocks[i].flag.used = 1 ;         {* 改變使用狀態               *{
        }

        if (counter == heapID->actblocks)      {* 足夠的空間 *{
            break;
    }



    {* 更正 memory pool 的大小 *{
    blksUsed  +=  heapID->actblocks ;


    #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
    Blocks_status_display();
    heapID_status_display(*heapID);
    #endif


    return Okay;
}
{*----------------------------------------------------------------------------*{
{* 功能 ： 刪除一個 STORheap，並釋放記憶體給 memory pool                      *{
{*                                                                            *{
{* 參數 ： struct STORheap  *heapID : STORheap 的資料結構                     *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              printf()                C  Run Time 程式庫                    *{
{*              Blocks_status_display() POWRSTOR    程式庫                    *{
{*              heapID_status_display() POWRSTOR    程式庫                    *{
{*----------------------------------------------------------------------------*{
STORstatus  delSheap( struct STORheap  *heapID )
{
unsigned int  i;
unsigned int  index;


    if( pwrInitialized == false ) {* POWRSTOR 尚未安裝 *{
        return NotInitialized;


    #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
    printf("delSheap(). \n");
    heapID_status_display(*heapID);
    #endif




    for(i=0; i< heapID->actblocks; i++)  {  {* 針對 STORheap 管理陣列的每一個元素 *{
        index = heapID->blocks[i];
        Blocks[ index ].flag.used = 0;      {* 改變使用狀態  *{
    }



    #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
    Blocks_status_display();
    #endif


    {* 更正 memory pool 的大小 *{
    blksUsed -= heapID->actblocks;

    {* 更正 STORheap 的大小 *{
    heapID->actblocks = 0;

    return Okay;
}
{*----------------------------------------------------------------------------*{
{* 功能 ： 增加 STORheap 的空間大小                                           *{
{*                                                                            *{
{*         原內容不受影響                                                     *{
{*                                                                            *{
{* 參數 ： struct STORheap  *heapID     : STORheap 的資料結構                 *{
{*         unsigned long    size        : 欲增加的空間大小 (bytes)            *{
{*         unsigned long    *newSegBase :                                     *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              printf()                C  Run Time 程式庫                    *{
{*              Blocks_status_display() POWRSTOR    程式庫                    *{
{*              heapID_status_display() POWRSTOR    程式庫                    *{
{*----------------------------------------------------------------------------*{
STORstatus  aloSheap( struct STORheap  *heapID,
                      unsigned long    size,
                      unsigned long    *newSegBase
                    )
{
int  counter = 0;
unsigned incblocks;
unsigned   i;
int  enoughflag = false;



    {* 把 bytes 轉換為 blocks *{
    incblocks = (size >> 14) + 1;   {* 可能會浪費一個 blocks *{


    {* memory pool 是否有足夠的空間 ? *{
    for(i=0, counter=0; i< VMEMBLOCKS; i++) {
        if ( Blocks[i].flag.used == 0 )   {     {* 此 block 尚未被使用 *{
             counter ++ ;                       {* 可用的 block 個數加 1 *{
        }

        if (counter == incblocks) {             {* 足夠的空間 *{
            enoughflag = true;
            break;
        }
    }


    if (! enoughflag)             {* memory pool 的空間不足 *{
        return NoMoreMem;


    {* 配置 memory pool 的記憶體空間到 STORheap 中 *{
    for(i=0,counter=0; i< VMEMBLOCKS; i++) {
        if ( Blocks[i].flag.used == 0 )   {                  {* 此 block 尚未被使用  *{
             heapID->blocks[counter+heapID->actblocks]= i;   {* 配置給 STORhrap      *{
             counter ++ ;                      {* 累計已配置的 block 個數 *{
             Blocks[i].flag.ID = heapID->ID ;  {* 記錄識別碼              *{
             Blocks[i].flag.used = 1 ;         {* 改變使用狀態            *{
        }

        if (counter == incblocks)      {* 足夠的空間 *{
            break;
    }


    {* 更正 STORheap 的大小 *{
    heapID->actblocks += incblocks ;


    {* 更正 memory pool 的大小 *{
    blksUsed  +=  incblocks ;



    #if (STORDEBUG)   {* 除錯階段, 列印出各項資料內容 *{
    printf("aloSheap().   size = %lu  incblocks = %u \n", size, incblocks );
    Blocks_status_display();
    heapID_status_display(*heapID);
    #endif


    return Okay;
}
{*----------------------------------------------------------------------------*{
{* 功能 ：  偵測 STORheap 的空間大小                                          *{
{*                                                                            *{
{* 參數 ：  struct STORheap  heapID : STORheap 的資料結構                     *{
{*          unsigned long    *size  : 此參數將傳回 STORheap 的空間大小(bytes) *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              無                                                            *{
{*                                                                            *{
{* 注意 ：  由於 POWRSTOR 是以 block 為單位，所以 *size 必將是                *{
{*          16384 (16K) 的整數倍                                              *{
{*----------------------------------------------------------------------------*{
STORstatus  sizSheap( struct STORheap  heapID,
                      unsigned long    *size
                    )
{
unsigned i ;



    if( pwrInitialized == false )  {* POWRSTOR 尚未安裝 *{
        return NotInitialized;


    *size = heapID.actblocks;  {* STORheap 的真正大小 (blocks) *{

    (*size) <<= 14;            {* 轉換 blocks 成為 bytes       *{

    return Okay;
}
{*----------------------------------------------------------------------------*{
{* 功能 ： 搬移 STORheap 中的資料到記憶體緩衝區 (DOS heap) 中                 *{
{*                                                                            *{
{* 參數 ： struct STORheap  heapID    : STORheap 的資料結構                   *{
{*         unsigned long    fromSTOR  : STORhrap 中的資料搬移起始位置         *{
{*         void             *toMemory : 記憶體緩衝區的起始位置                *{
{*         unsigned         num_bytes : 搬移的資料量 (bytes)                  *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              printf()                C  Run Time 程式庫                    *{
{*              heapID_status_display() POWRSTOR    程式庫                    *{
{*              EXPtoMem()              POWRDEVC    程式庫                    *{
{*              EXTget()                POWRDEVC    程式庫                    *{
{*              filGet()                POWRDEVC    程式庫                    *{
{*                                                                            *{
{* 注意 ： 原在 STORheap 的資料內容不受影響                                   *{
{*                                                                            *{
{*         原在記憶體緩衝區的資料內容將遭覆蓋                                 *{
{*----------------------------------------------------------------------------*{
STORstatus  getSTOR( struct STORheap  heapID,
                     unsigned long    fromSTOR,
                     void             *toMemory,
                     unsigned         num_bytes
                   )
{
unsigned blk;
unsigned blkAdr;
unsigned index;



    {* 首先計算 [blk:blkAdr] 的定址方式 *{
    blk =  fromSTOR >> 14;                 {* 第幾個 block          *{
    blkAdr = fromSTOR - (blk << 14);       {* block 內的第幾個 byte *{



    if (blk > heapID.actblocks)   {* 不合理的結果 *{
        return InvalidADR ;


    #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
    printf("getSTOR() \n");
    printf("toMemory = %p    fromSTOR = %lu   num_bytes = %u   blk = %u  blkAdr = %u \n", \
            toMemory, fromSTOR, num_bytes, blk, blkAdr );
    heapID_status_display(heapID);
    #endif



    index = heapID.blocks[blk] ;
    switch ( Blocks[index].type ) {        {* 哪一種記憶體型態 ? *{
        case  EXP_TYPE :  {* 擴展記憶體 *{
              blk = index - ExpFlag ;
              {* 作實際的記憶體搬移 *{
              EXPtoMem( ExpFrame, blk, blkAdr, toMemory, ExpHandle, num_bytes );
              break;

        case  EXT_TYPE :  {* 延伸記憶體 *{
              blk = index - ExtFlag ;
              {* 作實際的記憶體搬移 *{
              EXTget( ExtBase,  blk, blkAdr, toMemory, num_bytes ) ;
              break;

        case  DSK_TYPE :  {* 磁碟記憶體 *{
              blk = index - FileFlag ;
              {* 作實際的記憶體搬移 *{
              filGet( FileHandle, blk, blkAdr, toMemory, num_bytes );
              break;
    }


    #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
    printf("blk = %u \n", blk);
    #endif

    return Okay;
}
{*----------------------------------------------------------------------------*{
{* 功能 ： 搬移記憶體緩衝區 (DOS heap) 中的資料到 STORheap 中                 *{
{*                                                                            *{
{* 參數 ： struct STORheap  heapID      :  STORheap 的資料結構                *{
{*         void             *fromMemory :  記憶體緩衝區的起始位址             *{
{*         unsigned long    toSTOR      :  STORheap 接受資料的起始位置        *{
{*         unsigned         num_bytes   :  搬移的 bytes 個數                  *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              printf()                C  Run Time 程式庫                    *{
{*              heapID_status_display() POWRSTOR    程式庫                    *{
{*              MemtoEXP()              POWRDEVC    程式庫                    *{
{*              EXTput()                POWRDEVC    程式庫                    *{
{*              filPut()                POWRDEVC    程式庫                    *{
{*                                                                            *{
{* 注意 ： 原在記憶體緩衝區中的資料內容不受影響                               *{
{*                                                                            *{
{*         原在 STORheap 的中資料內容將遭覆蓋                                 *{
{*----------------------------------------------------------------------------*{
STORstatus  putSTOR( struct STORheap  heapID,
                     void             *fromMemory,
                     unsigned long    toSTOR,
                     unsigned         num_bytes
                   )
{
unsigned blk;
unsigned blkAdr;
unsigned index;



    {* 首先計算 [blk:blkAdr] 的定址方式 *{
    blk =  toSTOR >> 14;                   {* 第幾個 block          *{
    blkAdr = toSTOR - (blk << 14);         {* block 內的第幾個 byte *{



    if (blk > heapID.actblocks)            {* 不合理的結果 *{
        return InvalidADR ;


    #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
    printf("putSTOR() \n");
    printf("fromMemory = %p    toSTOR = %lu   num_bytes = %u   blk = %u  blkAdr = %u \n", \
            fromMemory, toSTOR, num_bytes, blk, blkAdr );
    heapID_status_display(heapID);
    #endif



    index = heapID.blocks[blk] ;
    switch ( Blocks[index].type ) {          {* 哪一種記憶體型態 ? *{
        case  EXP_TYPE :    {* 擴展記憶體 *{
              blk = index - ExpFlag ;
              {* 作實際的記憶體搬移 *{
              MemtoEXP( ExpFrame,  fromMemory, blk, blkAdr, ExpHandle, num_bytes );
              break;

        case  EXT_TYPE :    {* 延伸記憶體 *{
              blk = index - ExtFlag ;
              {* 作實際的記憶體搬移 *{
              EXTput( ExtBase, fromMemory, blk, blkAdr, num_bytes ) ;
              break;

        case  DSK_TYPE :    {* 磁碟記憶體 *{
              blk = index - FileFlag ;
              {* 作實際的記憶體搬移 *{
              filPut( FileHandle, fromMemory, blk, blkAdr, num_bytes );
              break;
    }


    #if (STORDEBUG)  {* 除錯階段, 列印出各項資料內容 *{
    printf("blk = %u \n", blk);
    #endif

    return Okay;
}
{*----------------------------------------------------------------------------*{
{* 功能 ： 檢查 POWRSTOR 的狀態代碼。                                         *{
{*                                                                            *{
{*         如果是 Okay，則迴返，                                              *{
{*         否則中斷程式，輸出狀態代碼至螢幕上。                               *{
{*                                                                            *{
{* 參數 ： STORstatus  stat  :  POWRSTOR 的狀態代碼                           *{
{*                                                                            *{
{* 迴返值 ：    POWRSTOR 狀態                                                 *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              abnormal()              POWRDEVC     程式庫                   *{
{*----------------------------------------------------------------------------*{
STORstatus  Sstatchk( STORstatus  stat )
{
    char  *errMsg;

    if( stat != Okay )
    {
        switch( stat )
        {
          case InvalInit      :  errMsg = "POWRSTOR MESSAGE: Invalid initialization??";
                                 break;
          case BadInitData    :  errMsg = "POWRSTOR MESSAGE: Bad initialization parameters??";
                                 break;
          case NotInitialized :  errMsg = "POWRSTOR MESSAGE: Not Active??";
                                 break;
          case NotEnoughMem   :  errMsg = "POWRSTOR MESSAGE: Not enough memory??";
                                 break;
          case FileERROR      :  errMsg = "POWRSTOR MESSAGE: Hard disk error??";
                                 break;
          case EXPerror       :  errMsg = "POWRSTOR MESSAGE: Expanded Memory error??";
                                 break;
          case EXTerror       :  errMsg = "POWRSTOR MESSAGE: Extended Memory error??";
                                 break;
          case InvalidADR     :  errMsg = "POWRSTOR MESSAGE: Invalid address argument??";
                                 break;
          case NoMoreMem      :  errMsg = "POWRSTOR MESSAGE: No more memory available??";
                                 break;
          case NoSuchHeap     :  errMsg = "POWRSTOR MESSAGE: No such STORheap??";
                                 break;
          case NoMoreHeaps    :  errMsg = "POWRSTOR MESSAGE: No more STORheaps available??";
                                 break;
          default             :  errMsg = "POWRSTOR MESSAGE: Unknown Status??";
                                 break;
        }
        abnormal( errMsg );   {* 輸出訊息到螢幕上，並結束程式 *{
    }
    return stat;
}


#if (STORDEBUG)   {* 除錯階段, 列印出各項資料內容 *{
{*----------------------------------------------------------------------------*{
{* 功能 ：   顯示 「POWRSTOR 管理陣列」的內容                                 *{
{*                                                                            *{
{* 參數 ：   無                                                               *{
{*                                                                            *{
{* 迴返值 ：    無                                                            *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              printf()                C  Run Time 程式庫                    *{
{*              getch()                 C  Run Time 程式庫                    *{
{*----------------------------------------------------------------------------*{
static void Blocks_status_display(void)
{
int i;

    {* 顯示「POWRSTOR 管理陣列」中每一個元素 (代表一個 block)  *{
    {* 的記憶體型態，和使用狀態  (每 15 筆資料就換行)          *{

    for( i=0; i<VMEMBLOCKS; i++)  {
         printf(" %2x%2x", Blocks[i].type,Blocks[i].flag);
         if (((i+1) % 15) == 0)   printf("\n");
    }
    printf("\n");
    getch();
}
{*----------------------------------------------------------------------------*{
{* 功能 ：   顯示 STORheap 的相關資訊                                         *{
{*                                                                            *{
{* 參數 ：   struct STORheap heapID : STORheap 的資料結構                     *{
{*                                                                            *{
{* 迴返值 ：    無                                                            *{
{*                                                                            *{
{* 外部常式 ：  名稱                    來源                                  *{
{*              printf()                C  Run Time 程式庫                    *{
{*              getch()                 C  Run Time 程式庫                    *{
{*----------------------------------------------------------------------------*{
static void heapID_status_display(struct STORheap heapID)
{
int i;

    {* 顯示 STORheap 的空間大小 (blocks) *{
    printf(" heapID.actblocks = %u \n", heapID.actblocks);

    {* 顯示 STORheap 的識別碼 *{
    printf(" heapID.ID        = %u \n", heapID.ID);

    {* 顯示 STORheap 的每一個 block 的記憶體型態 *{
    {* 每 15 筆資料換一行                        *{
    for (i=0 ; i< heapID.actblocks;  i++)  {
         printf(" %4u", heapID.blocks[i]);
         if (((i+1) % 15) == 0)   printf("\n");
    }

    printf("\n");
    getch();

}
{*----------------------------------------------------------------------------*{
#endif

{* ------------------------- end of file ---------------------------------- *{


