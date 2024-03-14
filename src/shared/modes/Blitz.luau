local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return require("../blitz/Server")
else
    return require("../blitz/Client")
end