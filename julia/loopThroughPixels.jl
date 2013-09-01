#  THis is my third take at a globes sript.  
#  I'm going to walk through pixel by pixel.

#  Note:  if you move to quaternions, all you need to do if you want a 
#  random walk on SO(3) is use small rotations q, and then for a new one,
#  left multiply the current rotation (q) by your new component, so 
#  q *= p.  


using Images
include("/home/pfoley/globesRepository/julia/globesFunctions.jl")
#globeImage = imread("/home/pfoley/globesRepository/earth-huge.png")
#globeImage = imread("/home/pfoley/globesRepository/peters-sat.jpg")
#newImage = imread("/home/pfoley/globesRepository/peters-sat.jpg")
#newImage = imread("/home/pfoley/globesRepository/earth-huge.png")

#globeImage = imread("/home/pfoley/large_earth.jpg")
#newImage = imread("/home/pfoley/large_earth.jpg")

globeImage = imread("/home/pfoley/Gall-peters_Largest.png")
newImage = imread("/home/pfoley/Gall-peters_Largest.png")

println("Read in the image ...")

(nc, nx, ny) = size(globeImage)
R = nx / (2*pi)
gamma = (ny * pi) / (nx)
#newImage = globeImage

image_size = (nx, ny)

theta_x = 0
theta_y = 0.6
theta_z = 0

rotMat = coordinateRotationFromXYZ(theta_x, theta_y, theta_z)

#  I may need to straight up copy this.
#newImage = globeImage

assignable_pixel_index = 1
#  Now loop through the image in the order in which you will assign values.
for y_index = 1:ny
for x_index = 1:nx

#  At each loop, you want to apply the full transformation to get the new_x and new_y.
#  Then put the correct pixel value in each color.  


#  Assign longitude and latitude.
longitude = (2*pi) * ((x_index / nx) - (1/2))
latitude = asin( (2 * y_index / ny)  - 1 )

#  Assign spatial coordinates
spatial_coordinates = 
    [cos(longitude)*cos(latitude) sin(longitude)*cos(latitude) sin(latitude)]

#  Rotate spatial coordinates
new_spatial_coordinates = rotMat * spatial_coordinates'

#  Obtain new longitude and latitude
new_longitude = atan2(new_spatial_coordinates[2], new_spatial_coordinates[1])
new_latitude = asin(new_spatial_coordinates[3])


#  Adjust to ensure longitudes and latitudes are in the appropriate ranges.
if new_longitude > pi
    new_longitude = new_longitude - (2*pi)
end


#  Obtain new pixel locations
#new_x = int(R*new_longitude)
#new_y = int(gamma * R * sin(new_latitude))
new_x = int( nx * ((1/2) + (new_longitude/(2*pi))))
new_y = int( ny * (1/2) * (1+sin(new_latitude)))

#  Ensure new pixels are within range
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

println("Completed image.  About to write the image...")
imwrite(newImage, "/home/pfoley/gpLarge1.png")
println("Wrote the image.")