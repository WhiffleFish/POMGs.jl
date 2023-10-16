module POMGs
# Maybe change to POSGs.jl ???

using ProgressMeter
using Random
import POMDPs
import POMDPTools
using POMDPTools.POMDPDistributions
using POMDPTools.BeliefUpdaters
using Reexport
using SparseArrays

include("distributions.jl")
export ProductDistribution

include("pomg.jl")

include("gen.jl")

include("gen_impl.jl")

include("sparse_tabular.jl")
export SparseTabularPOMG, SparseTabularMG

include("consistency_check.jl")

include(joinpath("BeliefUpdaters", "BeliefUpdaters.jl"))
@reexport using .BeliefUpdaters

include(joinpath("games", "games.jl"))

include(joinpath("solvers", "solvers.jl"))

include(joinpath("evaluation", "evaluation.jl"))

end # module
