--[[
	Basic dependency graph for structs created within a namespace
]]

local current: { [number]: any }?
local currentName: string

local namespaceDependencies = {}

function namespaceDependencies.start(name: string)
	current = {} :: { [number]: any }
	currentName = name
end

function namespaceDependencies.add(data)
	if not current then
		return
	end

	table.insert(current, data)
end

function namespaceDependencies.currentLength()
	return if current then #current else 0
end

function namespaceDependencies.currentName()
	return currentName
end

function namespaceDependencies.empty(): { [number]: any }
	if current == nil then
		return {}
	end

	local result = current
	current = nil

	return result
end

return namespaceDependencies