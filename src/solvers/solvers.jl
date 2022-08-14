"""
Train a CFR solver or whatever
"""
function train! end

include("policytree.jl")
include("CFR.jl")

export train!
export CFRSolver

