#  This is a script to make a movie.


resolution = 30

@parallel for i = 1:resolution

resolution = 30
ogName = "/home/pfoley/Gall-peters_Largest.png"
outputFolder = "/home/pfoley/globesRepository/secondMovie/"
include("/home/pfoley/globesRepository/julia/writeImageScript.jl")
#  Change this to parallel loop.

#  First loop through the y direction.
    theta_x = (i-1)*(1/resolution)*(2*pi)
    new_image_name = "$(outputFolder)image$(i).png"
    writeImage(theta_x,0,0,ogName,new_image_name)

end