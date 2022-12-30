@echo off
set workingDir=%cd%
cd %~dp0/..
haxe redistBuilder.hxml
hl bin/redistBuilder.hl
cd %workingDir%
pause