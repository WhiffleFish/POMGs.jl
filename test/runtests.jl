using POMGs
using POMGs.Games
using Test

@testset "smoke" begin
    game = MatrixGame()
    sol = CFRSolver(game)
    train!(sol, 10)
    
    s1 = sol.trees[1].nodes[1].s
    σ1 = s1 ./ sum(s1)
    s2 = sol.trees[2].nodes[1].s
    σ2 = s2 ./ sum(s2)

    @test length(sol.trees[1]) == length(sol.trees[1].nodes) == 1
    @test length(sol.trees[2]) == length(sol.trees[2].nodes) == 1

    @test all(σ1 .≈ 1/3)
    @test all(σ2 .≈ 1/3)

    # prisoner's dilemma
    game = MatrixGame([
        (-1,-1) (-3,0);
        (0,-3) (-2,-2)
    ])
    sol = CFRSolver(game)
    train!(sol, 10_000)

    s1 = sol.trees[1].nodes[1].s
    σ1 = s1 ./ sum(s1)
    s2 = sol.trees[2].nodes[1].s
    σ2 = s2 ./ sum(s2)
    
    @test length(sol.trees[1]) == length(sol.trees[1].nodes) == 1
    @test length(sol.trees[2]) == length(sol.trees[2].nodes) == 1

    @test isapprox(σ1,[0.,1.], atol=1e-2)
    @test isapprox(σ2,[0.,1.], atol=1e-2)
end

##
# game = Kuhn()
# sol = CFRSolver(game)
# train!(sol, 10_000)

# sol.trees[2].nodes[1].s


# s0 = initialstate(game)
# actions(game, s0)
# s,p = first(transition(game, s0, (0,0)))
# sp, pp = first(transition(game, s, (1,0)))