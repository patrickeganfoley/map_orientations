#  This is a script to make a movie.


resolution = 300

@parallel for i = 1:resolution

    resolution = 300
    ogName = "/home/pfoley/very_large_upsideDown.jpg"
    outputFolder = "/home/pfoley/globesRepository/fourthMovie/"
    include("/home/pfoley/globesRepository/julia/writeImageScript.jl")
    #  Change this to parallel loop.

    #  First loop through the y direction.
    theta_y = (i-1)*(1/resolution)*(2*pi)
    nameNumber = 100+i
    new_image_name = "$(outputFolder)image$(nameNumber).png"
    writeImage(0,theta_y,0,ogName,new_image_name)

end