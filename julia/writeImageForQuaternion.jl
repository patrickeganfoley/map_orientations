#  This script will write an image to file based on rotations.  That's all.
#  I'm just going to get a big-ass globe thing and maybe 1000 images, and show the 
#  globe rotating while you project it.

#  I assume here you've already read in "Images" and "globesFunctions"

#using Images
#include("/home/pfoley/globesRepository/julia/globesFunctions.jl")

function writeImageForQuaternion(q::quaternion, originalImage, newName)
    
    #globeImage = imread("/home/pfoley/globesRepository/earth-huge.png")
    #globeImage = imread("/home/pfoley/globesRepository/peters-sat.jpg")
    #newImage = imread("/home/pfoley/globesRepository/peters-sat.jpg")
    #newImage = imread("/home/pfoley/globesRepository/earth-huge.png")
    
    globeImage = imread(originalImage)
    newImage = imread(originalImage)
    
    println("Read in the image ...")
    
    (nc, nx, ny) = size(globeImage)
    R = nx / (2*pi)
    γ = (ny * pi) / (nx)
    #newImage = globeImage
    
    image_size = (nx, ny)
    
    
    
    assignable_pixel_index = 1
    #  Now loop through the image in the order in which you will assign values.
    for y_index = 1:ny
    
    #  Do just the y stuff here.  
    φ = asin( (2 * y_index / ny)  - 1 )    
    
    for x_index = 1:nx
    
    #  At each loop, you want to apply the full transformation to get the new_x and new_y.
    #  Then put the correct pixel value in each color.  
    
    
    #  Assign longitude.
    λ = (2*pi) * ((x_index / nx) - (1/2))
    
    newLocation = rotateByQuaternion(SphCoords(φ, λ), q)
    newφ = newLocation.φ
    newλ = newLocation.λ
    
    #  Adjust to ensure longitudes and latitudes are in the appropriate ranges.
    if newλ > pi
        newλ = newλ - (2*pi)
    end
    
    
    #  Obtain new pixel locations
    #new_x = int(R*new_longitude)
    #new_y = int(γ * R * sin(new_latitude))
    new_x = int( nx * ((1/2) + (newλ/(2*pi))))
    new_y = int( ny * (1/2) * (1+sin(newφ)))
    
    #  Ensure new pixels are within range
    #  This is why I'm sometimes shrinking things.  
    if new_x < 1
        new_x = 1
    end
    if new_y < 1
        new_y = 1
    end
    if new_x > nx
        new_x = nx
    end
    if new_y > ny
        new_y = ny
    end
    
    #  Now you can assign the pixels.
    newImage[assignable_pixel_index] = globeImage[1, new_x, new_y]     #R
    newImage[assignable_pixel_index + 1] = globeImage[2, new_x, new_y] #G
    newImage[assignable_pixel_index + 2] = globeImage[3, new_x, new_y] #B
    
    assignable_pixel_index += 3
    end
    
    #  Print out some progress.
    if (y_index % 10 == 0)
        completion_percentage = 100 *  y_index / ny
        println(completion_percentage, "% complete ...")
    end
    
    end
    
    #newImageName = "/home/pfoley/map$theta_x.$theta_y.$theta_z.png"
    println("Completed image.  About to write the image to $newName...")
    imwrite(newImage, newName)
    println("Wrote the image.")
    
end
