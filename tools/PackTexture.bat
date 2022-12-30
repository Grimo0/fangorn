@echo off
set workingDir=%cd%
cd %~dp0/..
haxe packerTexture.hxml
hl bin/packerTexture.hl
cd %workingDir%
pause