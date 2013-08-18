#  This script uses the functions in globesFunctions to:
#
#     Read in an image.
#     Compute longitude and latitude.
#     Rotate the globe.
#     Recompute pixel values
#     Get a new image with reoriented pixels.

using Images
include("/home/pfoley/globesRepository/julia/globesFunctions.jl")
globeImage = imread("/home/pfoley/globesRepository/earth-huge.png")
#globeImage = imread("/home/pfoley/globesRepository/peters-sat.jpg")

(nc, nx, ny) = size(globeImage)
image_size = (nx, ny)

theta_x = pi/3
theta_y = 0
theta_z = 0

rotMat = coordinateRotationFromXYZ(theta_x, theta_y, theta_z)





# Test for all the pixels. 
pixels = [ (i,j) for i = 1:nx, j = 1:ny ]
npixels = nx*ny
pixels = zeros(npixels,2)
cur = 1
for i = 1:nx
    for j = 1:ny
        pixels[cur,1] = i
        pixels[cur,2] = j
        cur += 1
     end
end

println("Generated the pixel thing ...")

longLat = longitudeAndLatitudeFromGallPetersPixels(pixels, image_size)
println("Got longitude and latitude")
spatialCoords = spatialCoordinatesFromLongitudeAndLatitude(longLat)
println("Got spatial Coordinates")
newSpatialCoords = (rotMat * spatialCoords')'
println("Rotated them...")
newLongLat = longitudeAndLatitudeFromSpatialCoordinates(newSpatialCoords)
println("Got new longitudes and latitudes")
newPixels = gallPetersPixels(newLongLat, image_size)
println("Got new pixel values")

#  Now I'm going to cheat and set min/max stuff.
for i = 1:npixels
    if newPixels[i,1] < 1
        newPixels[i,1] = 1
    end
    if newPixels[i,2] < 1
        newPixels[i,2] = 1
    end

    if newPixels[i,1] > nx
        newPixels[i,1] = nx
    end
    if newPixels[i,2] > ny
        newPixels[i,2] = ny
    end
end


println("Changed the max and min stuff ...")

#newImage = globeImage
#for color_index = 1:nc
#    for j = 1:nx
#        for k = 1:ny
#            new_j = newPixels[j, k]
#            new_k = newPixels[j, k]
#   #         newImage[color_index, j, k] = globeImage[color_index, new_j, new_k]
#        end
#    end
#    println("Finished reassigning pixel values for one color...")
#end


newImage = globeImage

#cur = 1
#for color_index = 1:nc
#    for j = 1:nx
#        for k = 1:ny#######

#            imageIndex = 

#            new_j = newPixels[cur, 1]
#            new_k = newPixels[cur, 2]
        
#        for color_index = 1:nc
#            newImage[color_index, j, k,] = globeImage[color_index, new_j, new_k] 
#        end

#            cur += 1
#        end
#    end

#    println("Changed vaues for one color...")
#end

image_index = 1
current_pixel = 1
for y_index = 1:ny
for x_index = 1:nx
for color_index = 1:nc

#  Get image pixel index.
current_pixel = ny*(x_index-1) + y_index
new_j = newPixels[current_pixel, 1]
new_k = newPixels[current_pixel, 2]

#  I know this looks bizarre.  It has to be like this, 
#  because you can access with three dimensions, but for some reason,
#  you can only write by indexing with one dimension.
newImage[image_index] = globeImage[color_index, new_j, new_k]

#image pixel index is c changes 1st, then x, then y.
image_index += 1


#println("image index is    ", image_index)
#println("new j is     ", new_j)
#println("new k is    ", new_k)
#println("current pixel is ", current_pixel)
#println("x index is  ", x_index)
#println("y index is  ", y_index)
#println("Finished one image column...")
end
end
end






println("About to write the image...")

#  Guessing at syntax here....
imwrite(newImage, "/home/pfoley/globesRepository/newImage1.png")
println("Wrote the image.")
