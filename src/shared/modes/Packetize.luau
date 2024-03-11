--!strict
--!optimize 2
--!native

local Packetize = require("../packetize")

return Packetize.defineNamespace('Benchmark', function()
    return {
        Booleans = Packetize.definePacket({
            value = Packetize.array(Packetize.bool),
        }),
        StructOfNumbers = Packetize.definePacket({
            value = Packetize.array(Packetize.struct({
                id = Packetize.uint16,
                x = Packetize.int8,
                y = Packetize.int16,
                z = Packetize.int8,
                orientation = Packetize.int16,
                animation = Packetize.uint8,
            })),
        }), 
    }
end)