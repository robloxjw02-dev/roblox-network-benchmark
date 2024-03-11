local Modes: { [string]: any } = {}

for _, Mode in script:GetChildren() do
    Modes[Mode.Name] = require(Mode)
end
return Modes