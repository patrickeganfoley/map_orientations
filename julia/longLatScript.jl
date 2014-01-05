include("/home/pfoley/globesRepository/julia/imageForTwoLocationsTest.jl")


phxLatitude = (33 + (27/60)) * (pi/180)
phxLongitude = - (112 + (4/60))*(pi/180)

ugaLatitude = - (0 + (42 + (36/60)/60)) * (pi / 180)
ugaLongitude = (31 + (24 + (18/60)/60)) * (pi /180)

phoenix = SphCoords(phxLatitude, phxLongitude)
uganda  = SphCoords(ugaLatitude, ugaLongitude)


ogImage = "/home/pfoley/globesRepository/small_sat_peters.jpg"
newName = "/home/pfoley/phxToUgandaGlobe_small2_tests.png"

# remove 'Test'. 
writeImageForTwoLocationsTest(
    phoenix, uganda,
    ogImage, newName)
