Base.@kwdef struct CompetitiveTiger <: POMG{Bool, Tuple{Int,Int}, Tuple{Bool,Bool}}
    r_listen::Float64           = -1.0
    r_findtiger::Float64        = -100.
    r_escapetiger::Float64      = 10.
    p_listen_correctly::Float64 = 0.85
    discount::Float64           = 0.95
end

const TIGER_LISTEN = 0
const TIGER_OPEN_LEFT = 1
const TIGER_OPEN_RIGHT = 2

const TIGER_LEFT = false
const TIGER_RIGHT = true

POMGs.discount(game::CompetitiveTiger) = game.discount

POMGs.states(::CompetitiveTiger) = (false, true)
POMGs.observations(::CompetitiveTiger) = (false, true)

POMGs.stateindex(::CompetitiveTiger, s::Bool) = Int(s) + 1
POMGs.player_actionindex(::CompetitiveTiger, i::Int, a::Int) = a + 1
POMGs.player_obsindex(::CompetitiveTiger, i::Int, o::Bool) = Int(o) + 1

function transition(::CompetitiveTiger, s::Bool, a::Int)
    if a == TIGER_OPEN_LEFT || a == TIGER_OPEN_RIGHT
        p = 0.5
    elseif s
        p = 1.0
    else
        p = 0.0
    end
    return BoolDistribution(p)
end
