local Benches = {}

for _, Bench in script:GetChildren() do
    Benches[Bench.Name] = require(Bench)
end
return Benches