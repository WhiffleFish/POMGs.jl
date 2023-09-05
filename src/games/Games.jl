module Games

using ..POMGs
using POMDPTools.POMDPDistributions
using StaticArrays
using Base.Iterators
using Random

include("distributions.jl")

include("matrix.jl")
export MatrixGame

include("kuhn.jl")
export Kuhn

end
