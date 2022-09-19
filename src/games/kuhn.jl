# enums ???
const NULL = -1
const PASS = 0
const BET = 1

"""
- `cards`       : vector containing card representation for each player
- `action_hist` : vector containing history of actions
    - `-1` : null action i.e. no action has been taken here
    - `0`  : check/fold
    - `1`  : bet
"""
struct KuhnState
    cards::SVector{2,Int}
    action_hist::SVector{3,Int}
end

KuhnState(cards::SVector{2,Int}) = KuhnState(cards, @SVector(fill(NULL,3)))

function Base.length(s::KuhnState)
    l = 0
    for a in s.action_hist
        a === NULL && break
        l += 1
    end
    return l
end

"""
Kuhn Poker
"Kuhn poker is an extremely simplified form of poker developed by Harold W. Kuhn as a
simple model zero-sum two-player imperfect-information game, amenable to a complete
game-theoretic analysis. In Kuhn poker, the deck includes only three playing cards,
for example a King, Queen, and Jack. One card is dealt to each player, which may place
bets similarly to a standard poker. If both players bet or both players pass, the player
with the higher card wins, otherwise, the betting player wins."
- https://en.wikipedia.org/wiki/Kuhn_poker
"""
struct Kuhn <: POMG{KuhnState, Tuple{Int,Int}, Int}
    chance_states::Categorical{KuhnState}
    function Kuhn()
        chance_states = [KuhnState(SVector(i,j)) for i in 1:3, j in 1:3 if i != j]
        return new(
            Categorical(
                chance_states,
                fill(inv(length(chance_states)), length(chance_states))
            )
        )
    end
end

player(::Kuhn, s) = any(iszero, s.cards) ? 0 : mod(length(s),2) + 1

POMGs.initialstate(::Kuhn) = KuhnState(SA[0,0], @SVector(fill(NULL,3)))

function POMGs.isterminal(::Kuhn, s::KuhnState)
    L = length(s)
    h = s.action_hist
    if L > 1
        return h[1] == BET || h[2] == PASS || L > 2
    else
        return false
    end
end

function POMGs.reward(::Kuhn, s::KuhnState, a, sp::KuhnState)
    as = sp.action_hist
    cards = s.cards

    modifier = cards[1] > cards[2] ? 1 : -1
    if as == SA[PASS, PASS, NULL]
        return modifier .* (1.,-1.)
    elseif as == SA[PASS, BET, PASS]
        return (-1., 1.)
    elseif as == SA[PASS, BET, BET]
        return modifier .* (2., -2.)
    elseif as == SA[BET, PASS, NULL]
        return (1., -1.)
    elseif as == SA[BET, BET, NULL]
        return modifier .* (2., -2.)
    else
        return (0.,0.)
    end
end

function POMGs.actions(g::Kuhn, s::KuhnState)
    p = player(g, s)
    return if iszero(p)
        (PASS:PASS, PASS:PASS)
    elseif isone(p) # player 1's turn
        (PASS:BET, PASS:PASS)
    else # player 2's turn
        (PASS:PASS, PASS:BET)
    end
end

function POMGs.transition(g::Kuhn, s::KuhnState, a) # not type stable... Union{Categorical, Deterministic}
    L = length(s)
    p = player(g, s)
    if iszero(p)
        return g.chance_states
    else
        return Deterministic(
            KuhnState(s.cards, setindex(s.action_hist, a[p], L+1))
        )
    end
end

function POMGs.observation(game::Kuhn, s::KuhnState, a::Tuple, sp::KuhnState)
    p = player(game, s)
    return if iszero(p)
        (sp.cards[1], sp.cards[2]) # not type stable...
    else
        (a[p], a[p])
    end
end

POMGs.discount(::Kuhn) = 1.0
