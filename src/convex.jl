using Convex, SCS, LinearAlgebra
export norm_diamond, diamond_distance
"""
$(SIGNATURES)
- `J`: matrix.
- `d1`: ?.
- `d2`: ?.

Return [diamond norm](https://arxiv.org/pdf/1004.4110.pdf) of matrix `J`.
"""
function norm_diamond(Φ::DynamicalMatrix{T}) where T<:AbstractMatrix{<:Number}
    J = Φ.matrix
    # TODO: compare d1, d2 with idim, odim
    d1 = Φ.idim
    d2 = Φ.odim
    X = ComplexVariable(d1*d2, d1*d2)
    t = 0.5*inner_product(X, J) + 0.5*inner_product(X', J')

    ρ₀ = ComplexVariable(d1, d1)
    ρ₁ = ComplexVariable(d1, d1)

    constraints = [ρ₀ in :SDP, ρ₁ in :SDP]
    constraints += tr(ρ₀) == 1
    constraints += tr(ρ₁) == 1
    constraints += [𝕀(d2) ⊗ ρ₀ X; X' 𝕀(d2) ⊗ ρ₁] in :SDP

    problem = maximize(t, constraints)
    solve!(problem, SCSSolver(verbose=0))
    print(problem)
    problem.optval
end

function norm_diamond(Φ::AbstractQuantumOperation{T}) where T<:AbstractMatrix{<:Number}
    norm_diamond(DynamicalMatrix{T}(ϕ))
end

"""
$(SIGNATURES)
- `J1`: matrix.
- `J2`: matrix.
- `d1`: ?.
- `d2`: ?.

Return [diamond distance](https://arxiv.org/pdf/1004.4110.pdf) between matrices `J1` and `J2`.
"""
function diamond_distance(Φ1::DynamicalMatrix{T}, Φ2::DynamicalMatrix{T}) where T<:AbstractMatrix{<:Number}
    J1 = Φ1.matrix
    J2 = Φ2.matrix
    # TODO: Test dimnesions
    Φ = DynamicalMatrix{T}(J1-J2, Φ1.idim, Φ1.odim)
    norm_diamond(Φ)
end

function diamond_distance(Φ1::AbstractQuantumOperation{T}, Φ2::AbstractQuantumOperation{T}) where T<:AbstractMatrix{<:Number}
    diamond_distance(DynamicalMatrix{T}(Φ1), DynamicalMatrix{T}(Φ2))
end
