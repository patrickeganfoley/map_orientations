include("coordinates.jl")

togo = SphCoords(pi/9, 0)
print("printing togo $(togo)")

togox = SpatialCoords(togo)
print("and spatially togo is $(togox) ")

togoback = SphCoords(togox)
print("now reconverted it's $(togoback) ")