@ECHO OFF
D:\TASM\TASM.EXE  /s /m /q /z %1 %2 %3 /I. /ID:\MY
IF NOT EXIST %1.OBJ GOTO EXIT
D:\TASM\TLINK.EXE /x /n /3 /ye /yx /t %1
IF EXIST %1.COM GOTO DEL
D:\TASM\TLINK.EXE /x /n /3 /ye /yx %1
:DEL
DEL %1.OBJ
:EXIT
