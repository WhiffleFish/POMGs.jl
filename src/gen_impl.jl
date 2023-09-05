gen(::POMG, s, a, rng) = NamedTuple()

"""
    DDNOut(x::Symbol)
    DDNOut{x::Symbol}()
    DDNOut(::Symbol, ::Symbol,...)
    DDNOut{x::NTuple{N, Symbol}}()

Reference to one or more named nodes in the POMDP or MDP dynamic decision network (DDN).

`DDNOut` is a "value type". See [the documentation of `Val`](https://docs.julialang.org/en/v1/manual/types/index.html#%22Value-types%22-1) for more conceptual details about value types.
"""
struct DDNOut{names} end

DDNOut(name::Symbol) = DDNOut{name}()
DDNOut(names...) = DDNOut{names}()
DDNOut(names::Tuple) = DDNOut{names}()

@generated function genout(v::DDNOut{symbols}, m::POMG, s, a, rng) where symbols

    # use anything available from gen(m, s, a, rng)
    expr = quote
        x = gen(m, s, a, rng)
        @assert x isa NamedTuple "gen(m::POMG, ...) must return a NamedTuple; got a $(typeof(x))"
    end
    
    # add gen for any other variables
    for (var, depargs) in POMDPs.sorted_deppairs(m, symbols)
        if var in (:s, :a) # input nodes
            continue
        end

        sym = Meta.quot(var)

        varblock = quote
            if haskey(x, $sym) # should be constant at compile time
                $var = x[$sym]
            else
                $var = $(POMDPs.node_expr(Val(var), depargs))
            end
        end
        append!(expr.args, varblock.args)
    end

    # add return expression
    if symbols isa Tuple
        return_expr = :(return $(Expr(:tuple, symbols...)))
    else
        return_expr = :(return $symbols)
    end
    append!(expr.args, return_expr.args)

    return expr
end

function POMDPs.sorted_deppairs(::Type{<:POMG}, symbols)
    deps = Dict(:s => Symbol[],
                :a => Symbol[],
                :sp => [:s, :a],
                :o => [:s, :a, :sp],
                :r => [:s, :a, :sp, :o],
                :info => Symbol[]
               )
    return POMDPs.sorted_deppairs(deps, symbols)
end
