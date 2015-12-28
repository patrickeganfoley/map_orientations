#  This script does everything on a per-pixel basis.

using Images
include("/Users/pfoley/globesRepository/julia/globesFunctions.jl")
#globeImage = imread("/home/pfoley/globesRepository/earth-huge.png")
globeImage = load("/Users/pfoley/globesRepository/input_images/peters-sat.jpg")

globeImageData = float(reinterpret(Uint8, data(globeImage))[1:3, :, :])


println("Read in the image ...")

(nc, nx, ny) = size(globeImageData)
newImage = globeImageData

image_size = (nx, ny)

theta_x = pi/4
theta_y = pi/7
theta_z = pi/3

rotMat = coordinateRotationFromXYZ(theta_x, theta_y, theta_z)
print("rotation matrix is")
print(rotMat)


image_index = 1
current_pixel = 1

for y_index = 1:ny
for x_index = 1:nx
for color_index = 1:nc


(new_j, new_k) = newPixelsFromPixels([x_index y_index], image_size, rotMat)

newImage[image_index] = globeImageData[color_index, new_j, new_k]

#image pixel index is c changes 1st, then x, then y.
image_index += 1


end
end
#  I guess I can do some calculations here and print a % done.

completion_percentage = 100 *  y_index / ny

println(completion_percentage, "% complete ...")
end

print("New image is")
print(newImage[:, 50:55, 100])
print("Old image was")
print(globeImageData[:, 50:55, 100])

myimg = shareproperties(newImage, globeImage)

println("Got all the new pixel values.  Now about to write the image.")
save("/Users/pfoley/newGlobeNewCode.png", myimg)
