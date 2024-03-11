local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modes = require("../shared/modes")
local Benches = require("../shared/benches")

function CompareTables(a, b)
    if a == b then 
        return true 
    end

    if type(a) ~= type(b) then 
        return false 
    end

    if type(a) ~= "table" then 
        return false 
    end

    local Keys = {}
    for Key, Value in a do
        local SecondaryValue = b[Key]
        if SecondaryValue == nil or not CompareTables(Value, SecondaryValue) then
            return false
        end
        Keys[Key] = true
    end

    for Key, _ in b do
        if not Keys[Key] then 
            return false 
        end
    end

    return true
end

local function CompareValues(a, b): boolean
    if type(a) == "table" or type(b) == "table" then
        return CompareTables(a, b)
    end
    return (a == b)
end

local Received = {}
for Name, Data in Benches do
    local function OnReceive(Tool: string)
        local ToolReceived = Received[Tool]
        if not ToolReceived then
            ToolReceived = {}
            Received[Tool] = ToolReceived
        end

        ToolReceived[Name] = 0

        return function(Player, Receive)
            ToolReceived[Name] += 1
            if ToolReceived[Name] > 1 then
                return
            end

            if not CompareValues(Data, Receive) then
                warn(`Received incorrect data with {Tool} for {Name}`)
            end
        end
    end
    
    for Tool, Events in Modes  do
        local LowerCaseTool = Tool:lower()
        local Event = Events[Name]
        local Callback = OnReceive(Tool)
        if LowerCaseTool == "speedy" then
            Event.setCallback(Callback)
        elseif LowerCaseTool == "packetize" then
            Event.listenTo(Callback)
        elseif LowerCaseTool == "swiftlink" then
            Event.setCallback(Callback)
        end
    end
end

ReplicatedStorage.Shared.GetReceived.OnServerInvoke = function()
    return Received
end