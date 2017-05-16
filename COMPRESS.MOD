MODULE Compress;


IMPORT
  Dos,
  Lib,
  Str,
  IO;


TYPE
  FName             = ARRAY [1..255] OF CHAR;


VAR
  OrgPath           : FName;
  SubStr            : ARRAY [1..2] OF CHAR;
  SubDirs           : BOOLEAN;


PROCEDURE Compress_Dir(DirName : ARRAY OF CHAR; SubDir : BOOLEAN);
  VAR
    SearchName      : FName;
    TempName        : FName;
    DirHandle       : Dos.HDIR;
    SearchBuf       : Dos.FILEFINDBUF;
    SearchCount     : CARDINAL;
    First           : BOOLEAN;
    Buffer          : ARRAY [1..1024] OF CHAR;
    BytesRead       : CARDINAL;
    BytesWritten    : CARDINAL;
    Dummy           : CARDINAL;
    OK              : BOOLEAN;
  BEGIN
    DirHandle   := 0FFFFH;
    SearchCount := 1;
    First       := TRUE;
    Str.Copy(SearchName, DirName);
    Str.Append(SearchName, '*');
    Str.Copy(TempName, DirName);
    Str.Append(TempName, 'Mikaels.$$$');
    WHILE (First AND (Dos.FindFirst(SearchName,DirHandle,CARDINAL({1,4}),SearchBuf,SIZE(SearchBuf),SearchCount,0) = 0)) OR
          (NOT First AND (Dos.FindNext(DirHandle,SearchBuf,SIZE(SearchBuf),SearchCount) = 0)) DO
      First := FALSE;
      IF NOT (4 IN BITSET(SearchBuf.attrFile)) THEN
        IO.WrStr(DirName);
        IO.WrStr(SearchBuf.name);
        IO.WrStr(' <- ');
        OK := FALSE;
        Str.Concat(SearchBuf.name, DirName, SearchBuf.name);
        IF Dos.Copy(SearchBuf.name, TempName, CARDINAL({0}), 0) = 0 THEN
          IF Dos.Delete(SearchBuf.name, 0) = 0 THEN
            IF Dos.Move(TempName, SearchBuf.name, 0) = 0 THEN
              OK := TRUE;
            END;
          END;
        END;
        IF OK THEN
          IO.WrStr('OK');
        ELSE
          IO.WrStr('Failed');
        END;
        IO.WrLn;
      ELSIF (Str.Compare('.',SearchBuf.name) <> 0) AND (Str.Compare('..',SearchBuf.name) <> 0) AND SubDir THEN
        Str.Concat(SearchBuf.name, DirName, SearchBuf.name);
        Str.Concat(SearchBuf.name, SearchBuf.name, '\');
        Compress_Dir(SearchBuf.name, SubDir);
      END;
      IF IO.KeyPressed() AND (IO.RdKey() = CHR(27)) THEN
        IO.WrLn;
        IO.WrStr('Terminated by user');  IO.WrLn;
        IO.WrLn;
        HALT;
      END;
    END;
  END Compress_Dir;


BEGIN
  IF (Lib.ParamCount() = 0) OR (Lib.ParamCount() > 2) THEN
    IO.WrLn;
    IO.WrStr('Usage: ');   IO.WrLn;
    IO.WrLn;
    IO.WrStr('  Compress <path> [/S]');  IO.WrLn;
    IO.WrLn;
    IO.WrStr('    <path>     Path to be compressed (syntax: C:\Dir\');   IO.WrLn;
    IO.WrStr('    [/S]       Compress subdirectories (optional)');   IO.WrLn;
    IO.WrLn;
    IO.WrStr('  Example: Compress \ /S    compresses the entire hard disk');  IO.WrLn;
    IO.WrLn;
  ELSE
    SubDirs := FALSE;
    Lib.ParamStr(OrgPath, 1);
    IF Lib.ParamCount() > 1 THEN
      Lib.ParamStr(SubStr, 2);
      Str.Caps(SubStr);
      IF Str.Compare('/S', SubStr) = 0 THEN
        SubDirs := TRUE;
      ELSE
        IO.WrLn;
        IO.WrStr('Invalid option: ');
        IO.WrStr(SubStr);
        IO.WrLn;
        IO.WrLn;
        HALT;
      END;
    END;
    IO.WrLn;
    IO.WrStr('OS/2 disk compression.        (c) 1991 by Mikael Wahlgren');   IO.WrLn;
    IO.WrStr("Press <Esc> to exit (don't Ctrl-Break!)");   IO.WrLn;
    IO.WrLn;
    Compress_Dir(OrgPath, SubDirs);
  END;
END Compress.
