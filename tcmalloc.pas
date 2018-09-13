{
  tcmalloc.pas

  This unit installs a custom memory manager that delegates all memory management
  to the TCMalloc.dll file

  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
  If a copy of the MPL was not distributed with this file, You can obtain one
  at https://mozilla.org/MPL/2.0/.
}
unit tcmalloc;

interface

{$DEBUGINFO OFF}

const
  TCMallocDll = 'libtcmalloc.dll';

procedure ReleaseFreeMemory;
procedure SetMemoryReleaseRate(rate: Double);
function GetMemoryReleaseRate: Double;

// returns some details about the current allocated memory.
// Note that end of lines are in the Linux format
function GetStats(Detailed: Boolean = False): string;

implementation

type
  size_t = NativeUInt;

function tc_malloc(Size: size_t): Pointer; cdecl; external TCMallocDLL;
function tc_calloc(Num: size_t; Size: size_t): Pointer; cdecl; external TCMallocDLL;
function tc_realloc(P: Pointer; Size: size_t): Pointer; cdecl; external TCMallocDLL;
procedure tc_free(P: Pointer); cdecl; external TCMallocDLL;
procedure MallocExtension_ReleaseFreeMemory(); cdecl; external TCMallocDLL;
procedure MallocExtension_SetMemoryReleaseRate(rate: Double); cdecl; external TCMallocDLL;
function MallocExtension_GetMemoryReleaseRate: Double; cdecl; external TCMallocDLL;
procedure MallocExtension_GetStats(Buffer: PAnsiChar; Length: Integer); cdecl; external TCMallocDLL;

procedure ReleaseFreeMemory;
begin
  MallocExtension_ReleaseFreeMemory;
end;

procedure SetMemoryReleaseRate(rate: Double);
begin
  MallocExtension_SetMemoryReleaseRate(rate);
end;

function GetMemoryReleaseRate: Double;
begin
  Result := MallocExtension_GetMemoryReleaseRate;
end;

function GetStats(Detailed: Boolean = False): string;
var
  Buffer: TArray<AnsiChar>;
begin
  if Detailed then
    SetLength(Buffer, 20 * 1024)
  else
    SetLength(Buffer, 4 * 1024);

  MallocExtension_GetStats(@Buffer[0], Length(Buffer));

  Result := string(PAnsiChar(@Buffer[0]));
end;


function GetMem(Size: NativeInt): Pointer;
begin
  Result := tc_malloc(size);
end;

function FreeMem(P: Pointer): Integer;
begin
  tc_free(P);
  Result := 0;
end;

function ReallocMem(P: Pointer; Size: NativeInt): Pointer;
begin
  Result := tc_realloc(P, Size);
end;

function AllocMem(Size: NativeInt): Pointer;
begin
  Result := tc_calloc(1, Size);
end;

function RegisterUnregisterExpectedMemoryLeak(P: Pointer): Boolean;
begin
  Result := False;
end;

const
  MemoryManager: TMemoryManagerEx = (
    GetMem: GetMem;
    FreeMem: FreeMem;
    ReallocMem: ReallocMem;
    AllocMem: AllocMem;
    RegisterExpectedMemoryLeak: RegisterUnregisterExpectedMemoryLeak;
    UnregisterExpectedMemoryLeak: RegisterUnregisterExpectedMemoryLeak
  );

procedure InstallTCMalloc;
begin
  SetMemoryManager(MemoryManager);
end;

initialization
  InstallTCMalloc;

end.
