module Games

using ..POMGs
using StaticArrays
using Base.Iterators
using Random

include("distributions.jl")

include("matrix.jl")
export MatrixGame

include("kuhn.jl")
export Kuhn

end
