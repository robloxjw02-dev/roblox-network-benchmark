repeat
	task.wait()
until game:IsLoaded()
local Modes = require("../shared/modes")
local Benches = require("../shared/benches")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

type Benchmark = {
	Sent: number,
	Receive: number,
	Bandwidth: { number },
	Framerate: { number },
}

type ToolResults = {
	[string]: Benchmark,
}

local SEND_AMOUNT = 1000

local Connection
local Total = 0
local Sent = 0
local Frames = 0

function jsonPrettify(tbl: {}, indentLevel: number?)
    local indentLevel = indentLevel or 0
    local function indent(level)
        return string.rep("    ", level)
    end
    local function formatValue(value, level)
        if type(value) == "string" then
            return '"' .. value .. '"'
        elseif type(value) == "number" then
            return tostring(value)
        elseif type(value) == "boolean" then
            return tostring(value)
        elseif type(value) == "table" then
            return jsonPrettify(value, level)
        else
            return "null"
        end
    end
    local jsonString = "{\n"
    local count = 0
    for key, value in pairs(tbl) do
        jsonString = jsonString .. indent(indentLevel + 1) .. '"' .. key .. '": '
        if type(value) == "table" then
            jsonString = jsonString .. jsonPrettify(value, indentLevel + 1)
        else
            jsonString = jsonString .. formatValue(value, indentLevel + 1)
        end
        count = count + 1
        -- Check if there are more elements to add
        if next(tbl, key) ~= nil then
            jsonString = jsonString .. ",\n"
        end
    end
    jsonString = jsonString .. "\n" .. indent(indentLevel) .. "}"
    return jsonString
end

-- function jsonPrettify(tbl: {}, indentLevel: number?)
--     local indentLevel = indentLevel or 0
--     local function indent(level)
--         return string.rep("    ", level)
--     end
--     local function formatValue(value, level)
--         if type(value) == "string" then
--             return '"' .. value .. '"'
--         elseif type(value) == "number" then
--             return tostring(value)
--         elseif type(value) == "boolean" then
--             return tostring(value)
--         elseif type(value) == "table" then
--             return jsonPrettify(value, level)
--         else
--             return "null"
--         end
--     end
--     local jsonString = "{\n"
--     for key, value in tbl do
--         jsonString = jsonString .. indent(indentLevel + 1) .. '"' .. key .. '": '
--         if type(value) == "table" then
--             jsonString = jsonString .. jsonPrettify(value, indentLevel + 1)
--         else
--             jsonString = jsonString .. formatValue(value, indentLevel + 1)
--         end
--         jsonString = jsonString .. ",\n"
--     end
--     jsonString = jsonString .. indent(indentLevel) .. "}"
--     return jsonString
-- end

local function Percentile(Samples: { number }, Percentile: number)
	assert(
		(Percentile // 1) == Percentile and Percentile >= 0 and Percentile <= 100,
		"Percentile must be an integer between 0 and 100"
	)
	local Index = ((#Samples * (Percentile / 100)) // 1)
	Index = math.max(Index, 1)
	return Samples[Index]
end

local function RunBenchmark(Tool: string, Bench: string): Benchmark
	local LowerCaseTool = Tool:lower()
	local Bandwidth = {}
	local Framerates = {}

	local Data = Benches[Bench]
	local Events = Modes[Tool]

	local Event = Events[Bench]
	local Method

	if LowerCaseTool == "packetize" then
		Method = function(Data)
			Event.send(Data)
		end
	elseif LowerCaseTool == "speedy" then
		Method = function(Data)
			Event.fire(Data)
		end
	elseif LowerCaseTool == "swiftlink" then
		Method = function(Data)
			Event.send(Data)
		end
	end

	Connection = RunService.PostSimulation:Connect(function(DeltaTime: number)
		Total += DeltaTime
		Frames += 1

		if Total >= 1 then
			Total -= 1
			table.insert(Bandwidth, Stats.DataSendKbps)
			table.insert(Framerates, Frames)
			Frames = 0
		end

		for Index = 1, SEND_AMOUNT do
			Sent += 1
			Method(Data)
		end
	end)

	task.wait(5)
	Connection:Disconnect()

	--> Generate results
	table.sort(Framerates)

	local FrameratePercentiles = {}
	local BandwidthPercentiles = {}

	for _, Percentage in { 50, 0, 80, 90, 95, 100 } do
		table.insert(BandwidthPercentiles, Percentile(Bandwidth, Percentage))
		table.insert(FrameratePercentiles, Percentile(Framerates, Percentage))
	end

	return {
		Sent = Sent,
		Receive = 0,
		Bandwidth = BandwidthPercentiles,
		Framerate = FrameratePercentiles,
	}
end

local function RunBenchmarks()
	local Results: { [string]: ToolResults } = {}

	for Bench in Benches do
		if not Results[Bench] then
			Results[Bench] = {}
		end
		print(`> Running {Bench}`)
		for Tool in Modes do
			warn(`Running {Bench} with {Tool}...`)
			Results[Bench][Tool] = RunBenchmark(Tool, Bench)
			Total = 0
			Frames = 0
			Sent = 0
			task.wait(5)
		end
		task.wait(2)
	end

	local Received = ReplicatedStorage.Shared.GetReceived:InvokeServer()
	for Tool, Benchmarks in Received do
		for Bench, Receive in Benchmarks do
			Results[Bench][Tool].Receive = Receive
		end
	end

	print("Finished running benchmarks, generating results...")

	local OutputJSON = Instance.new("StringValue")
	OutputJSON.Name = "Result"
	OutputJSON.Value = HttpService:JSONEncode(Results)
	OutputJSON.Parent = game

	print("Generated results")
	print("===== Table Format =====")
	print(Results)
    print(jsonPrettify(Results))
	print("===== JSON Format =====")
	print(OutputJSON.Value)
end

task.wait(1)
warn("Benchmark Started")
RunBenchmarks()
