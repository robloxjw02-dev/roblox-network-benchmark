@echo off

setlocal
:PROMPT
SET "AREYOUSURE=N"
SET /P "AREYOUSURE=Download tools? (Y/[N])?"
IF /I %AREYOUSURE% NEQ Y GOTO COMPILE

echo Downloading dependencies...
rmdir /s /q ".\tools"
rmdir /s /q ".\packages"
mkdir ".\tools"
mkdir ".\packages"
lune run "./scripts/download"
del /q ".\tools\*.zip"
del /q ".\packages\*.zip"

:COMPILE
echo Compiling definitions
if exist "./src/shared/speedy" rmdir /s /q "./src/shared/speedy"
if exist "./src/shared/blitz" rmdir /s /q "./src/shared/blitz"

mkdir "./src/shared/speedy"
mkdir "./src/shared/blitz"
"./tools/speedy.exe" "./definitions/definition.speedy"
"./tools/blitz.exe" "./definitions/definition.blitz"
endlocal

echo Building ROBLOX place
if exist out rmdir /s /q  out
if exist "./Benchmark.rbxl" del "./Benchmark.rbxl"
mkdir out
rojo sourcemap default.project.json --output sourcemap.json --include-non-scripts
darklua process src out

rojo build build.project.json --output "./Benchmark.rbxl"

setlocal
SET "OPENSTUDIO=N"
SET /P OPENSTUDIO=Open generated place? (Y/[N])?
if /I %OPENSTUDIO% NEQ Y GOTO END

lune run "./scripts/generate"

:END
endlocal