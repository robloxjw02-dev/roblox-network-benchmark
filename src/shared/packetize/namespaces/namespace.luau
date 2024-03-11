--[[
	The file that contains the function for handling and creating namespace.
	namespace aren't really anything special, they are just an encapsulation to make it easier to manage packets and structs.
	
	Dependency management is fun!
]]

local RunService = game:GetService("RunService")

local values = require("../replicated/values")
local types = require("../types")
local namespaceDependencies = require("./namespaceDependencies")
local packetIDs = require("./packetIDs")

local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

local count = 0

return function(
	name: string,
	input: () -> {
		[string]: any,
	}
)
	local namespaceReplicator = values.access(name)

	namespaceDependencies.start(name)
	local packets: {
		[string]: (id: number) -> any,
	} = input()
	local structs = namespaceDependencies.empty()

	local result = {}

	if runContext == "server" then
		local constructedNamespace = {
			structs = {},
			packets = {},
		}

		for key in packets do
			count += 1
			constructedNamespace.packets[key] = count
			result[key] = packets[key](count)

			packetIDs.set(count, result[key])
		end

		for index, value in structs do
			constructedNamespace.structs[index] = value
		end

		namespaceReplicator:write(constructedNamespace)
	elseif runContext == "client" then
		-- yes, this means that packets technically don't need to be defined on the client
		-- we do it anyway for typechecking and perf shortcuts
		local namespaceData = namespaceReplicator:read() :: types.namespaceData

		for key, packet in packets do
			result[key] = packet(namespaceData.packets[key])

			packetIDs.set(namespaceData.packets[key], result[key])
		end
	end

	return result
end