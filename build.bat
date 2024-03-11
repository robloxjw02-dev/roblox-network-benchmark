@echo off

:COMPILE
echo Compiling definitions
if exist "./src/shared/speedy" rmdir "./src/shared/speedy"
if exist "./src/shared/swiftlink" rmdir "./src/shared/swiftlink"
if exist "./Benchmark.rbxl" rmdir "./Benchmark.rbxl"

mkdir "./src/shared/speedy"
mkdir "./src/shared/swiftlink"
"./tools/speedy.exe" "./definitions/definition.speedy"
"./tools/swift-link.exe" "./definitions/definition.swfl"
endlocal

echo Building ROBLOX place
if exist out rmdir out
if exist "./Benchmark.rbxl" del "./Benchmark.rbxl"
mkdir out
rojo sourcemap default.project.json --output sourcemap.json --include-non-scripts
darklua process src out

rojo build build.project.json --output "./Benchmark.rbxl"

setlocal
SET "OPENSTUDIO=N"
SET /P OPENSTUDIO=Open generated place? (Y/[N])?
if /I %OPENSTUDIO% NEQ Y GOTO END

start Benchmark.rbxl