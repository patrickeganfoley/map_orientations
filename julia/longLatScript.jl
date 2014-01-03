include("/home/pfoley/globesRepository/julia/imageForTwoLocations.jl")

phxLatitude = (33 + (27/60)) * (pi/180)
phxLongitude = - (112 + (4/60))*(pi/180)

ugaLatitude = (0 + (18 + (49/60)/60)) * (pi / 180)
ugaLongitude = (32 + (34 + (52/60)/60)) * (pi /180)

ogImage = "/home/pfoley/globesRepository/small_sat_peters.jpg"
newName = "/home/pfoley/phxToUgandaGlobe_small.png"

writeImageForTwoLocations(
    (phxLongitude, phxLatitude),
    (ugaLongitude, ugaLatitude),
    ogImage,
    newName)
