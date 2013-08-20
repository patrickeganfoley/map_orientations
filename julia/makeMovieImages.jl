#  This is a script to make a movie.

ogName = "/home/pfoley/Gall-peters_Largest.png"
outputFolder = "/home/pfoley/globesRepository/firstMovie/"
include("/home/pfoley/globesRepository/julia/writeImageScript.jl")
#  Change this to parallel loop.

#  First loop through the y direction.
resolution = 15

for i = 1:100

    theta_y = (i-1)*(1/resolution)*(2*pi)
    new_image_name = "$(outputFolder)image$(i).png"
    writeImage(0,theta_y,0,ogName,new_image_name)


end