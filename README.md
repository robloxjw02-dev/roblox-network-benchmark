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

## Results (Last Updated 03/15/24 00:59:50 UTC)
`P[NUMBER]` = [NUMBER] Percentile

*The tables below were automatically generated by this [script](https://github.com/robloxjw02-dev/roblox-network-benchmark/blob/main/generate.luau).*

## Tool Versions
`speedy`: v0.1.3  
`packetize`: v0.1.2  
`blitz`: v0.1.3  
## Computer Specs
Processor: `AMD Ryzen 5 5600X 6-Core Processor `  
Memory #1: `17GB 3200`  
Memory #2: `17GB 3200`  
## [Booleans](https://github.com/robloxjw02-dev/roblox-network-benchmark/blob/main/src/shared/benches/Booleans.luau)
|Tool (FPS)|Median|P0|P80|P90|P95|P100|Data Sent|Data Receive|Loss (%)|
|---|---|---|---|---|---|---|---|---|---|
|Speedy|40.00|39.00|41.00|41.00|41.00|41.00|404,000|404,000|0%|
|Packetize|26.00|26.00|27.00|27.00|27.00|28.00|266,000|266,000|0%|
|Blitz|60.00|60.00|60.00|60.00|60.00|60.00|601,000|601,000|0%|

|Tool (Kbps)|Median|P0|P80|P90|P95|P100|Data Sent|Data Receive|Loss (%)|
|---|---|---|---|---|---|---|---|---|---|
|Speedy|22.33|13.64|21.96|22.03|22.03|21.65|404,000|404,000|0%|
|Packetize|22.66|11.96|22.00|22.92|22.92|22.19|266,000|266,000|0%|
|Blitz|21.65|17.18|21.83|21.94|21.94|21.80|601,000|601,000|0%|
## [StructOfNumbers](https://github.com/robloxjw02-dev/roblox-network-benchmark/blob/main/src/shared/benches/StructOfNumbers.luau)
|Tool (FPS)|Median|P0|P80|P90|P95|P100|Data Sent|Data Receive|Loss (%)|
|---|---|---|---|---|---|---|---|---|---|
|Speedy|28.00|26.00|28.00|29.00|29.00|29.00|278,000|278,000|0%|
|Packetize|27.00|26.00|27.00|28.00|28.00|29.00|272,000|272,000|0%|
|Blitz|33.00|32.00|33.00|33.00|33.00|35.00|328,000|328,000|0%|

|Tool (Kbps)|Median|P0|P80|P90|P95|P100|Data Sent|Data Receive|Loss (%)|
|---|---|---|---|---|---|---|---|---|---|
|Speedy|62.47|40.66|61.04|63.45|63.45|62.29|278,000|278,000|0%|
|Packetize|62.63|32.94|64.86|62.01|62.01|62.34|272,000|272,000|0%|
|Blitz|61.13|35.99|63.69|61.72|61.72|61.84|328,000|328,000|0%|