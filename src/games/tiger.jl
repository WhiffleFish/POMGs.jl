Base.@kwdef struct CompetitiveTiger <: POMG{Bool, Tuple{Int,Int}, Tuple{Symbol,Symbol}}
    r_listen::Float64           = -1.0
    r_findtiger::Float64        = -100.
    r_escapetiger::Float64      = 10.
    p_listen_correctly::Float64 = 0.85
    discount::Float64           = 0.95
end

const TIGER_LISTEN = 0
const TIGER_OPEN_LEFT = 1
const TIGER_OPEN_RIGHT = 2
const TIGER_BLOCK = 3

const TIGER_LEFT = false
const TIGER_RIGHT = true

POMGs.discount(game::CompetitiveTiger) = game.discount

POMGs.initialstate(::CompetitiveTiger) = Uniform((false, true))

POMGs.states(::CompetitiveTiger) = (false, true)
POMGs.actions(::CompetitiveTiger) = (0:3, 0:3)
POMGs.observations(::CompetitiveTiger) = ((:left, :right, :nothing), (:left, :right, :nothing))

POMGs.stateindex(::CompetitiveTiger, s::Bool) = Int(s) + 1
POMGs.player_actionindex(::CompetitiveTiger, i::Int, a::Int) = a + 1
POMGs.player_obsindex(::CompetitiveTiger, i::Int, o::Bool) = Int(o) + 1

function POMGs.transition(::CompetitiveTiger, s::Bool, a::Tuple{Int,Int})
    if a == TIGER_OPEN_LEFT || a == TIGER_OPEN_RIGHT
        p = 0.5
    elseif s
        p = 1.0
    else
        p = 0.0
    end
    return BoolDistribution(p)
end

function POMGs.reward(::CompetitiveTiger, s::Bool, a::Tuple{Int,Int})
    a1,a2 = a
    p1_reward = if a1 == 3
        if a2 == 3
           0.
        elseif a2 == 0
            -1.
        elseif a2 == 1
            s == TIGER_LEFT ? -1. : 1.
        elseif a2 == 2
            s == TIGER_LEFT ? 1. : -1.
        end
    elseif a1 == 0
        if a2 == 3
            1.
        elseif a2 == 0
            0.
        elseif a2 == 1
            s == TIGER_LEFT ? 4. : -2.
        elseif a2 == 2
            s == TIGER_LEFT ? -2. : 4.
         end
    elseif a1 == 1
        if a2 == 3
            s == TIGER_LEFT ? 1. : -1.
        elseif a2 == 0
            s == TIGER_LEFT ? -4. : 2.
        elseif a2 == 1
            0.
        elseif a2 == 2
            s == TIGER_LEFT ? -6. : 6.
        end
    elseif a1 == 2
        if a2 == 3
            s == TIGER_LEFT ? 1. : -1.
        elseif a2 == 0
            s == TIGER_LEFT ? 2. : -4.
        elseif a2 == 1
            0.
        elseif a2 == 2
            s == TIGER_LEFT ? 6. : -6.
        end
    end
    return (p1_reward, -p1_reward)
end

# TODO: not using `p_listen_correctly` game field
# TODO: using product distributions would be a lot easier
# FIXME: Not type stable
function POMGs.observation(::CompetitiveTiger, a, sp)
    a1, a2 = a
    return if iszero(a1)
        if iszero(a2)
            if sp == TIGER_LEFT
                SparseCat(
                    [(:left, :left), (:left, :right), (:right, :left), (:right, :right)], 
                    [0.7225, 0.1275, 0.1275, 0.0225]
                )
            else
                SparseCat(
                    [(:left, :left), (:left, :right), (:right, :left), (:right, :right)], 
                    [0.0225, 0.1275, 0.1275, 0.7225]
                )
            end
        else
            if sp == TIGER_LEFT
                SparseCat([(:left, :nothing), (:right, :nothing)], [0.85, 0.15])
            else
                SparseCat([(:left, :nothing), (:right, :nothing)], [0.15, 0.85])
            end
        end
    elseif iszero(a2)
        if sp == TIGER_LEFT
            SparseCat([(:nothing, :left), (:nothing, :right)], [0.85, 0.15])
        else
            SparseCat([(:nothing, :left), (:nothing, :right)], [0.15, 0.85])
        end
    else
        Deterministic((:nothing, :nothing))
    end
end

# FIXME: Not type stable
function POMGs.player_observation(::CompetitiveTiger, p::Int, a::Tuple{Int,Int}, sp::Bool)
    return if iszero(a[p])
        if sp == TIGER_LEFT
            SparseCat(SA[:left, :right], SA[0.85, 0.15])
        else
            SparseCat(SA[:left, :right], SA[0.15, 0.85])
        end
    else
        Deterministic(:nothing)
    end
end
