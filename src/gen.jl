function gen end

macro gen(symbols...)
    quote
        # this should be an anonymous function, but there is a bug (https://github.com/JuliaLang/julia/issues/36272)
        f(m, s, a, rng=Random.default_rng()) = genout(DDNOut($(symbols...)), m, s, a, rng)
    end
end
