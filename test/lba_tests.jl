@safetestset "LBA Tests" begin
    @safetestset "LBA Test1" begin
        using SequentialSamplingModels, Test, Random
        include("KDE.jl")
        Random.seed!(10542)

        dist = LBA(ν = [3.0, 2.0], A = 0.8, k = 0.2, τ = 0.3)
        choice, rt = rand(dist, 10^5)
        rt1 = rt[choice .== 1]
        p1 = mean(x -> x == 1, choice)
        p2 = 1 - p1
        approx_pdf = kde(rt1)
        x = 0.2:0.01:1.5
        y′ = pdf(approx_pdf, x) * p1
        y = pdf.(dist, (1,), x)
        @test y′ ≈ y rtol = 0.03

        rt2 = rt[choice .== 2]
        approx_pdf = kde(rt2)
        x = 0.2:0.01:1.5
        y′ = pdf(approx_pdf, x) * p2
        y = pdf.(dist, (2,), x)
        @test y′ ≈ y rtol = 0.03
    end

    @safetestset "LBA Test2" begin
        using SequentialSamplingModels, Test, Random
        include("KDE.jl")
        Random.seed!(8521)

        # note for some values, tests will fail
        # this is because kde is sensitive to outliers
        # density overlay on histograms are valid
        dist = LBA(ν = [2.0, 2.7], A = 0.6, k = 0.26, τ = 0.4)
        choice, rt = rand(dist, 10^5)
        rt1 = rt[choice .== 1]
        p1 = mean(x -> x == 1, choice)
        p2 = 1 - p1
        approx_pdf = kde(rt1)
        x = 0.2:0.01:1.5
        y′ = pdf(approx_pdf, x) * p1
        y = pdf.(dist, (1,), x)
        @test y′ ≈ y rtol = 0.03

        rt2 = rt[choice .== 2]
        approx_pdf = kde(rt2)
        x = 0.2:0.01:1.5
        y′ = pdf(approx_pdf, x) * p2
        y = pdf.(dist, (2,), x)
        @test y′ ≈ y rtol = 0.03
    end

    @safetestset "LBA Test3" begin
        using SequentialSamplingModels, Test, Random
        include("KDE.jl")
        Random.seed!(851)

        # note for some values, tests will fail
        # this is because kde is sensitive to outliers
        # density overlay on histograms are valid
        dist = LBA(ν = [2.0, 2.7], A = 0.4, k = 0.20, τ = 0.4, σ = [1.0, 0.5])
        choice, rt = rand(dist, 10^5)
        rt1 = rt[choice .== 1]
        p1 = mean(x -> x == 1, choice)
        p2 = 1 - p1
        approx_pdf = kde(rt1)
        x = 0.2:0.01:1.5
        y′ = pdf(approx_pdf, x) * p1
        y = pdf.(dist, (1,), x)
        @test y′ ≈ y rtol = 0.03

        rt2 = rt[choice .== 2]
        approx_pdf = kde(rt2)
        x = 0.2:0.01:1.5
        y′ = pdf(approx_pdf, x) * p2
        y = pdf.(dist, (2,), x)
        @test y′ ≈ y rtol = 0.03
    end

    @safetestset "LBA loglikelihood" begin
        using SequentialSamplingModels
        using Test
        using Random
        Random.seed!(8521)

        dist = LBA(ν = [2.0, 2.7], A = 0.6, k = 0.26, τ = 0.4)
        choice, rt = rand(dist, 10)

        sum_logpdf = logpdf.(dist, choice, rt) |> sum
        loglike = loglikelihood(dist, (; choice, rt))
        @test sum_logpdf ≈ loglike
    end

    @safetestset "simulate" begin
        using SequentialSamplingModels
        using Test
        using Random

        Random.seed!(8477)
        A = 0.80
        k = 0.20
        α = A + k
        dist = LBA(; A, k, ν = [2, 1])

        time_steps, evidence = simulate(dist; Δt = 0.001)

        @test time_steps[1] ≈ 0
        @test length(time_steps) == size(evidence, 1)
        @test size(evidence, 2) == 2
        @test maximum(evidence[end, :]) ≈ α atol = 0.005
    end

    @safetestset "CDF" begin
        @safetestset "1" begin
            using Random
            using SequentialSamplingModels
            using StatsBase
            using Test

            Random.seed!(522)
            n_sim = 20_000
            dist = LBA(ν = [3.0, 2.0], A = 0.8, k = 0.2, τ = 0.3)
            choice, rt = rand(dist, n_sim)

            ul, ub = quantile(rt, [0.05, 0.95])
            for t ∈ range(ul, ub, length = 10)
                sim_x = mean(choice .== 1 .&& rt .≤ t)
                x = cdf(dist, 1, t)
                @test sim_x ≈ x atol = 1e-2
            end
        end

        @safetestset "2" begin
            using Random
            using SequentialSamplingModels
            using StatsBase
            using Test

            Random.seed!(301)
            n_sim = 20_000
            dist = LBA(ν = [1.0, 1.5], A = 0.4, k = 0.4, τ = 0.3)
            choice, rt = rand(dist, n_sim)
            ul, ub = quantile(rt, [0.05, 0.95])
            for t ∈ range(ul, ub, length = 10)
                sim_x = mean(choice .== 1 .&& rt .≤ t)
                x = cdf(dist, 1, t)
                @test sim_x ≈ x atol = 1e-2
            end
        end
    end
end
