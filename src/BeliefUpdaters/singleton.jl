# TODO: Any way to check if there's a one-to-one correspondance between history and state?
struct SingletonUpdater{G}
    game::G
end

function POMDPs.update(upd::SingletonUpdater, b::Deterministic, a, o)
    game = upd.game
    s = b.s
    T = transition(game, s, a)
    T_support = support(T)
    if isone(length(T_support))
        return only(T_support)
    else
        for sp ∈ T_support
            !iszero(observation(game, s, a, sp)) && return Deterministic(sp)
        end
        error("""
            Failed belief update - no nonzero observation probabilities

            s = $s
            a = $a
            o = $o
        """)
    end
end
