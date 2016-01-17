import numpy as np

def transform_map(map_image, rot_mat, debug = True):
    ny, nx, _ = map_image.shape
    mapdims = (nx, ny)
    
    if debug:
        print 'ny, nx are {} and {}'.format(ny, nx)
    xs, ys = np.meshgrid(np.arange(0, nx), np.arange(0, ny))
    xs = xs.flatten().astype(float)
    ys = ys.flatten().astype(float)
    if debug:
        print 'shape of xs and ys are {} and {}'.format(xs.shape, ys.shape)
        print 'xs min and max are {} and {}'.format(min(xs), max(xs))
        print 'ys min and max are {} and {}'.format(min(ys), max(ys))


    longs, lats = longitudeAndLatitudeFromGPPixel(xs, ys, mapdims)
    if debug:
        print 'shape of longs and lats are {} and {}'.format(longs.shape, lats.shape)
        print'longitudes histogram'
        plt.hist(longs)
        print 'latitudes histogram'
        plt.hist(lats)

    xxs, yys, zzs = spatialCoordinatesFromLongitudeAndLatitude(longs, lats)
    if debug:
        print 'pre rotation hists'
        plt.hist(xxs)
        plt.hist(yys)
        plt.hist(zzs)
    new_xxyyzz = np.dot(rot_mat, np.array([xxs, yys, zzs]))
    
    new_xxs = np.squeeze(np.array(new_xxyyzz[0, :]))
    new_yys = np.squeeze(np.array(new_xxyyzz[1, :]))
    new_zzs = np.squeeze(np.array(new_xxyyzz[2, :]))
    if debug:
        print 'post rotation hists'
        plt.hist(new_xxs)
        plt.hist(new_yys)
        plt.hist(new_zzs)

    new_longs, new_lats = longitudeAndLatitudeFromSpatialCoordinates(new_xxs, new_yys, new_zzs)
    if debug:
        print 'new longs'
        plt.hist(new_longs)
        print 'new lats'
        plt.hist(new_lats)
    new_xs, new_ys = gall_peters_pixels(new_longs, new_lats, mapdims)
    if debug:
        print 'new x pixels and new y pixels'
        plt.hist(new_xs)
        plt.hist(new_ys)

        print 'shape of new xs and new ys is '
        new_xs.shape
        new_ys.shape
    
        print 'ny, nx are {}, and {}'.format(ny, nx)
    
    
    new_xs.shape = (ny, nx)
    new_ys.shape = (ny, nx)
    
    new_map = deepcopy(map_image)
    new_map[:, :, 0] = map_image[new_ys, new_xs, 0]
    new_map[:, :, 1] = map_image[new_ys, new_xs, 1]
    new_map[:, :, 2] = map_image[new_ys, new_xs, 2]
    
    plt.imshow(new_map)
    return(new_map)

def longitudeAndLatitudeFromGPPixel(x, y, mapdims):
    nx, ny = mapdims
    #  GP Projection:
    #
    #  x = R lambda / sqrt(2)
    #  y = R sqrt(2) sin(phi)
    #     lambda is longitude (left right)
    #     phi is latitude (up down)
    #     R is radius of globe, we'll use 1.0
    #  lambda = (x/R) * sqrt(2)
    #  phi = arcsin((y/R) / sqrt(2))
    #
    longitude = (x * ((2.0 * np.pi / nx) + np.pi )) % (2.0 * np.pi)
    latitude = np.arcsin(2.0 * ( (y / ny) - (0.5)) )
    return(longitude, latitude)

def spatialCoordinatesFromLongitudeAndLatitude(longitude, latitude):
    #longitude, latitude = longLat
    x = np.cos(longitude) * np.cos(latitude)
    y = np.sin(longitude) * np.cos(latitude)
    z = np.sin(latitude)
    return(x, y, z)


def longitudeAndLatitudeFromSpatialCoordinates(nxs, nys, nzs):
    latitude = np.arcsin(nzs)
    longitude = np.arctan2(nys, nxs)
    longitude = (longitude + 2 * np.pi) % (2 * np.pi)
    
    return((longitude, latitude))


def gall_peters_pixels(longitude, latitude, mapdims):
    nx, ny = mapdims
    longitude = (longitude + 2 * np.pi) % (2*np.pi)

    #  I need to flip longitudes.  
    need_to_be_flipped = np.greater(longitude, np.pi)
    longitude = longitude - need_to_be_flipped * (longitude) - need_to_be_flipped * (2*np.pi - longitude)
    
    u = nx * (0.5 + (longitude / (2*np.pi)))
    #if (np.pi <= longitude <= (2*np.pi)):
    #    u = int( nx * (longitude - np.pi) / (2*np.pi))
    
    v = (ny/2) * (np.sin(latitude)+1.0)
    
    u = u.astype(int)
    v = v.astype(int)
    
    return((u, v))


def rotationMatrix(axis_vector, angle):
    axis_vector = axis_vector / np.sqrt(sum(axis_vector**2))
    (x, y, z) = axis_vector
    
    #  en.wikipedia.org/wiki/Rotation_matrix#Roataion matrix from axis and angle
    tensor_product_matrix = np.matrix([
            [x**2, x*y, x*z],
            [x*y, y**2, y*z],
            [x*z, y*z, z**2]
        ])
    cross_product_matrix = np.matrix([
            [0.0, -z, y],
            [z, 0.0, -x],
            [-y, x, 0.0]
        ])
    R = np.eye(3) * np.cos(angle) + \
        cross_product_matrix * np.sin(angle) + \
        tensor_product_matrix * (1 - np.cos(angle))
    
    return R

def rotationFromXYZ(angle_x, angle_y, angle_z):
    r_x = rotationMatrix(np.array([1.0, 0.0, 0.0]), angle_x)
    r_y = rotationMatrix(np.array([0.0, 1.0, 0.0]), angle_y)
    r_z = rotationMatrix(np.array([0.0, 0.0, 1.0]), angle_z)
    
    return (np.dot(np.dot(r_x, r_y), r_z))
