module POMGs
# Maybe change to POSGs.jl ???

using ProgressMeter
using Random
import POMDPs
using POMDPTools.POMDPDistributions
using POMDPTools.BeliefUpdaters
using Reexport

include("distributions.jl")
export ProductDistribution

include("pomg.jl")

include("gen.jl")

include("gen_impl.jl")

include(joinpath("BeliefUpdaters", "BeliefUpdaters.jl"))
@reexport using .BeliefUpdaters

include(joinpath("games", "games.jl"))

include(joinpath("solvers", "solvers.jl"))

include(joinpath("evaluation", "evaluation.jl"))

end # module
