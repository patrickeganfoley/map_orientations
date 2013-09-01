immutable Quaternion{T <: Real} <: Number
    re::T
    i::T
    j::T
    k::T
end

Quaternion(a::Real, b::Real, c::Real, d::Real) = Quaternion(promote(x,y)...)
Quaternion(a::Real) = Quaternion(a, zero(a), zero(a), zero(a))

#  Define type aliases for different sizes.
typealias Quaternion256 Quaternion{Float64}
typealias Quaternion128 Quaternion{Float32}
typealias Quaternion64  Quaternion{Float16}

sizeof(::Type{Quaternion256}) = 32
sizeof(::Type{Quaternion128}) = 16
sizeof(::Type{Quaternion64}) = 8

#  Declare components.
real(q::Quaternion) = q.re
i(q::Quaternion)    = q.i
j(q::Quaternion)    = q.j
k(q::Quaternion)    = q.k

#  Convert quaternions of one Type to another Type
convert{T<:Real}(::Type{Quaternion{T}}, x::Real) = 
    Quaternion{T}(convert(T,x), convert(T,0), convert(T,0), convert(T,0))
convert{T<:Real}(::Type{Quaternion{T}}, q::Quaternion{T}) = q
convert{T<:Real}(::Type{Quaternion{T}}, q::Quaternion) = 
    Quaternion{T}(convert(T,real(q)), convert(T, i(q)), convert(T,j(q)), convert(T,k(q)))


#  I'm at line 30ish.  I need to repeat all this stuff for up to 150 for this to work.
#  Maybe I should just use an array of 4 numbers and write my own multiplications...