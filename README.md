# Roblox Network Benchmark 

## Running the benchmarks
Run these commands:
```
aftman install
& "./build.bat"
```

## Methodology
Benchmarks are done by firing the event 1000 times per frame with the same data every frame for 10 seconds. 

Source code can be found here [here](https://github.com/robloxjw02-dev/roblox-network-benchmark/blob/main/src).  
Data used for benchmarks can be found [here](https://github.com/robloxjw02-dev/roblox-network-benchmark/blob/main/src/shared/benches).   
Definition files used for benchmarks can be found [here](https://github.com/robloxjw02-dev/roblox-network-benchmark/blob/main/definitions).  
## Results (Last Updated 03/14/24 10:50:16 UTC)
`P[NUMBER]` = [NUMBER] Percentile

*The tables below were automatically generated by this [script](https://github.com/robloxjw02-dev/roblox-network-benchmark/blob/main/generate.luau).*

## Tool Versions
`speedy`: v0.1.1  
`packetize`: v0.1.2  
`blitz`: v0.1.0  
## Computer Specs
Processor: `AMD Ryzen 5 5600X 6-Core Processor `  
Memory #1: `17GB 3200`  
Memory #2: `17GB 3200`  
## [Booleans](https://github.com/robloxjw02-dev/roblox-network-benchmark/blob/main/src/shared/benches/Booleans.luau)
|Tool (FPS)|Median|P0|P80|P90|P95|P100|Loss (%)|
|---|---|---|---|---|---|---|---|
|Speedy|41.00|41.00|42.00|42.00|42.00|42.00|0%|
|Packetize|26.00|26.00|27.00|27.00|27.00|29.00|0%|
|Blitz|60.00|60.00|60.00|60.00|60.00|60.00|0%|

|Tool (Kbps)|Median|P0|P80|P90|P95|P100|Loss (%)|
|---|---|---|---|---|---|---|---|
|Speedy|21.86|13.36|21.76|22.31|22.31|21.85|0%|
|Packetize|22.69|11.96|22.45|21.66|21.66|22.97|0%|
|Blitz|21.93|16.81|21.95|21.98|21.98|21.71|0%|
## [StructOfNumbers](https://github.com/robloxjw02-dev/roblox-network-benchmark/blob/main/src/shared/benches/StructOfNumbers.luau)
|Tool (FPS)|Median|P0|P80|P90|P95|P100|Loss (%)|
|---|---|---|---|---|---|---|---|
|Speedy|28.00|26.00|28.00|29.00|29.00|29.00|0%|
|Packetize|29.00|28.00|30.00|30.00|30.00|31.00|0%|
|Blitz|32.00|30.00|33.00|33.00|33.00|34.00|0%|

|Tool (Kbps)|Median|P0|P80|P90|P95|P100|Loss (%)|
|---|---|---|---|---|---|---|---|
|Speedy|61.88|41.28|62.17|63.39|63.39|60.67|0%|
|Packetize|62.97|30.75|61.30|62.98|62.98|62.11|0%|
|Blitz|62.66|35.57|60.34|62.46|62.46|62.78|0%|