local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return require("../speedy/Server")
else
    return require("../speedy/Client")
end