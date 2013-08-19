#  This script does everything on a per-pixel basis.

using Images
include("/home/pfoley/globesRepository/julia/globesFunctions.jl")
#globeImage = imread("/home/pfoley/globesRepository/earth-huge.png")
globeImage = imread("/home/pfoley/globesRepository/peters-sat.jpg")


println("Read in the image ...")

(nc, nx, ny) = size(globeImage)
newImage = globeImage

image_size = (nx, ny)

theta_x = pi/4
theta_y = pi/7
theta_z = pi/3

rotMat = coordinateRotationFromXYZ(theta_x, theta_y, theta_z)



image_index = 1
current_pixel = 1
for y_index = 1:ny
for x_index = 1:nx
for color_index = 1:nc

#  Get image pixel index.
#current_pixel = ny*(x_index-1) + y_index
#new_j = newPixels[current_pixel, 1]
#new_k = newPixels[current_pixel, 2]

(new_j, new_k) = newPixelsFromPixels([x_index y_index], image_size, rotMat)

#println("image index is    ", image_index)
#println("new j is     ", new_j)
#println("new k is    ", new_k)
#println("current pixel is ", current_pixel)
#println("x index is  ", x_index)
#println("y index is  ", y_index)
#println("Finished one image column...")


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
#  I guess I can do some calculations here and print a % done.

completion_percentage = 100 *  y_index / ny

println(completion_percentage, "% complete ...")
end



println("Got all the new pixel values.  Now about to write the image.")
imwrite(newImage, "/home/pfoley/newGlobe24.png")
