function evaluate(sol, s)
    game = sol.game
    γ = discount(game)
    if isterminal(game, s)
        return 0.0
    else
        v = (0.0, 0.0) # any way to extend this + loops to N-player games? 
        for a1 ∈ actions(game, s, 1), a2 ∈ actions(game, s, 2)
            for (sp, prob) ∈ transition(game, s, (a1,a2))
                r = reward(s, (a1,a2), sp)
                v .+= prob .* (r .+ γ .* evaluate(sol, sp))
            end
        end
        return v
    end
end
