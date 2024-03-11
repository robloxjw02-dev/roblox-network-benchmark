local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return require("../swiftlink/Server")
else
    return require("../swiftlink/Client")
end