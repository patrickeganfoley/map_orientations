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
include("/home/pfoley/globesRepository/julia/writeImageForQuaternion.jl")

#  I'm just fucking around for the moment, trying to get a few interesting maps.

#ogImage = "/home/pfoley/globesRepository/small_sat_peters.jpg"
#ogImage = "/home/pfoley/globesRepository/earth-huge.png"
#ogImage = "/home/pfoley/globesRepository/bigWorld.jpg"
ogImage = "/home/pfoley/globesRepository/peters-political2.jpg"
newName = "/home/pfoley/politicalmoving.png"

smallAngle = pi/10

axis = [0.0, 1.0, 0.0]

slightlyDown = quaternion([cos(smallAngle/2), sin(smallAngle/2) .* [0, 1.0, 0.0] ])
slightlyCounterClockwise = quaternion([ cos(smallAngle/2), sin(smallAngle/2) .* [1.0, 0.0, 0.0]])

#testQuaternion = quaternion([cos(smallAngle/2), sin(smallAngle/2) .* axis])
##    testQuaternion = ((((((slightlyCounterClockwise * slightlyCounterClockwise) * slightlyCounterClockwise) * slightlyCounterClockwise)  * slightlyDown) * slightlyDown) * slightlyDown);
##    
##    writeImageForQuaternion(testQuaternion, ogImage, newName)
##    writeImageForQuaternion(testQuaternion, ogImage, "/home/pfoley/new1.png")
##    
##    #  dece images 
##    testQuaternion = slightlyCounterClockwise * (slightlyDown * (slightlyDown * slightlyDown));
##    writeImageForQuaternion(testQuaternion, ogImage, "/home/pfoley/new2.png")
##    
##    testQuaternion = slightlyCounterClockwise * slightlyCounterClockwise * slightlyDown * slightlyDown * slightlyDown;
##    writeImageForQuaternion(testQuaternion, ogImage, "/home/pfoley/new3.png")
##    
##    testQuaternion = slightlyCounterClockwise * slightlyCounterClockwise * slightlyCounterClockwise * slightlyDown * slightlyDown * slightlyDown;
##    writeImageForQuaternion(testQuaternion, ogImage, "/home/pfoley/new4.png")
##    
##    testQuaternion = slightlyCounterClockwise * slightlyCounterClockwise * slightlyCounterClockwise * slightlyCounterClockwise * slightlyDown * slightlyDown * slightlyDown;
##    writeImageForQuaternion(testQuaternion, ogImage, "/home/pfoley/new5.png")
##    


axis = [1.0, 0.0, 0.0] #  slightly counterclockwise.  asia up, usa down.  
axis = [-1.0, 0.0, 0.0] # slightly clockwise.  asia down, usa up.  
axis = [0, 1.0, 0.0] # pull everything slightly down.  

curquaternion = quaternion([1.0, 0.0, 0.0, 0.0 ])

#  Now make some randoms.  
for iter = 1:1000

    rotationAxis = rand(Normal(), 3)
    rotationAxis ./= norm(rotationAxis)

    #  Move by a tenth of a degree.  That should be abour 6 miles or so.  No this is straight up one degree.  About 60 miles.  
    rotationAngle = (2*pi/360)

    rotQuat = quaternion( [ cos(rotationAngle/2), sin(rotationAngle/2) .* rotationAxis ] )
    
    curquaternion = rotQuat * curquaternion

    newName = "/home/pfoley/movingpoliticalmapTakeThree$(iter).png"
    writeImageForQuaternion(curquaternion, ogImage, newName)

end

#  Now save that quaternion if you want.  
#  Nah.  