## This script takes in:
##     * originalImage - some png or jpeg globe
##     * newName       - a string / file location for the new image.
##     * location1     - a (longitude, latitude) tuple
##     * location2     - a (longitude, latitude) tuple
## And produces a new image.

using Images
using Distributions

include("/home/pfoley/globesRepository/julia/globesFunctions.jl")
include("/home/pfoley/globesRepository/julia/positioningFunctions.jl")
include("/home/pfoley/globesRepository/julia/newWriteImage.jl")

ogImage = "/home/pfoley/globesRepository/bigWorld.jpg"
newName = "/home/pfoley/randTest.png"

smallAngle = pi/10

axis = [0.0, 1.0, 0.0]

slightlyDown = quaternion([cos(smallAngle/2), sin(smallAngle/2) .* [0, 1.0, 0.0] ])
slightlyCounterClockwise = quaternion([ cos(smallAngle/2), sin(smallAngle/2) .* [1.0, 0.0, 0.0]])




axis = [1.0, 0.0, 0.0] #  slightly counterclockwise.  asia up, usa down.  
axis = [-1.0, 0.0, 0.0] # slightly clockwise.  asia down, usa up.  
axis = [0, 1.0, 0.0] # pull everything slightly down.  


rotationAxis = rand(Normal(), 3)
rotationAxis ./= norm(rotationAxis)

rotationAngle = 2 * pi * rand(1)

rotQuat = quaternion( [ cos(rotationAngle/2), sin(rotationAngle/2) .* rotationAxis ] )
    
newName = "/home/pfoley/newtestglobe.png"
test = mapforquaternion(rotQuat, ogImage, newName)
