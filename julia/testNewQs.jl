include("lazyQuaternion.jl")

q = randomVersor(pi/4)

println("q is $q ")
println("multypliy by 2 $(2.0 * q)")
println("or add $(q + q)")
println("or subtract $(q - q)")
println("multiply $(q * q)")

x = [1.0 0 0]
println("And multiply by a vector $(q * x) ")
println("And the other way $(x * q) ")

println("Now rotate. $(rotateByQuaternion(x, q)) .")
