@echo off
set /p LOGIN=Enter Steam login:
set /p PASSWORD=Enter password:
set STEAMSDKPATH=C:\Steam SDK
"%STEAMSDKPATH%\tools\ContentBuilder\builder\steamcmd.exe" +login %LOGIN% %PASSWORD% +run_app_build "%~dp0steam_app_build_win.vdf" +quit
pause