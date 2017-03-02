import numpy as np
import matplotlib.pyplot as plt


def transform_map(map_image, rot_mat,
                  in_projection='platecarre',
                  out_projection='platecarre',
                  display=True,
                  debug=False):

    invalid_projection_msg = (
        "Please choose a projection from "
        "'platecarre' or 'gallpeters'."
    )

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

    if in_projection == 'platecarre':
        longs, lats = longitudeAndLatitudeFromPCPixel(xs, ys, mapdims)
    elif in_projection == 'gallpeters':
        longs, lats = longitudeAndLatitudeFromGPPixel(xs, ys, mapdims)
    else:
        raise ValueError(invalid_projection_msg)

    if debug:
        print 'shape of longs and lats are {} and {}'.format(
            longs.shape, lats.shape)
        print 'longitudes histogram'
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

    new_longs, new_lats = longitudeAndLatitudeFromSpatialCoordinates(
        new_xxs, new_yys, new_zzs)
    if debug:
        print 'new longs'
        plt.hist(new_longs)
        print 'new lats'
        plt.hist(new_lats)

    if out_projection == 'platecarre':
        new_xs, new_ys = pixel_for_plate_carre(new_longs, new_lats, mapdims)
    elif out_projection == 'gallpeters':
        new_xs, new_ys = gall_peters_pixels(new_longs, new_lats, mapdims)
    else:
        raise ValueError(invalid_projection_msg)

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

    new_map = np.zeros(dtype = map_image.dtype,
                       shape = map_image.shape)

    new_map[:, :, 0] = map_image[new_ys, new_xs, 0]
    new_map[:, :, 1] = map_image[new_ys, new_xs, 1]
    new_map[:, :, 2] = map_image[new_ys, new_xs, 2]

    if display:
        plt.imshow(new_map)
    return(new_map)


def longitudeAndLatitudeFromGPPixel(x, y, mapdims):
    """
    GP Projection:

    x = R lambda / sqrt(2)
    y = R sqrt(2) sin(phi)
        lambda is longitude (left right)
        phi is latitude (up down)
        R is radius of globe, we'll use 1.0
    lambda = (x/R) * sqrt(2)
    phi = arcsin((y/R) / sqrt(2))
    """
    nx, ny = mapdims
    longitude = x * (2.0 * np.pi / float(nx)) - np.pi
    latitude = np.arcsin(2.0 * ((y / ny) - (0.5)))
    return(longitude, latitude)


def longitudeAndLatitudeFromPCPixel(x, y, mapdims):
    nx, ny = mapdims
    longitude = 2*np.pi * ((x / float(nx)) - 0.5)
    latitude = - (np.pi * ((y / float(ny)) - 0.5))
    return(longitude, latitude)


def spatialCoordinatesFromLongitudeAndLatitude(longitude, latitude):
    x = np.cos(longitude) * np.cos(latitude)
    y = np.sin(longitude) * np.cos(latitude)
    z = np.sin(latitude)
    return(x, y, z)


def flip_longitudes(longitude):
    #  which need to be flipped?
    inds = np.greater(longitude, np.pi)
    longitude = longitude - 2*np.pi * inds
    return(longitude)


def longitudeAndLatitudeFromSpatialCoordinates(xxs, yys, zzs):
    latitude = np.arcsin(zzs)
    longitude = np.arctan2(yys, xxs)
    longitude = flip_longitudes(longitude)
    return((longitude, latitude))


def gall_peters_pixels(longitude, latitude, mapdims):
    nx, ny = mapdims

    u = nx * (0.5 + (longitude / (2*np.pi)))
    v = (ny/2) * (np.sin(latitude)+1.0)

    u = u.astype(int)
    v = v.astype(int)

    #  Happens w/ rounding.
    u[u == nx] = nx - 1
    v[v == ny] = 0

    return((u, v))


def pixel_for_plate_carre(longitude, latitude, mapdims):
    nx, ny = mapdims

    u = nx * (0.5 + (longitude / (2*np.pi)))
    v = - (ny * (0.5 + (latitude / np.pi)))

    u = u.astype(int)
    v = v.astype(int)

    u[u == nx] = nx - 1
    v[v == ny] = ny - 1

    return(u, v)


def rotationMatrix(axis_vector, angle):
    axis_vector = axis_vector / np.sqrt(sum(axis_vector**2))
    (x, y, z) = axis_vector

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


def rotationFromTwoLocations(
        longlatA,
        longlatB):
    """
    Given two tuples (longitude and latitude),
    finds a rotation that places the first center left,
    and the second center right.
    """
    vec1 = spatialCoordinatesFromLongitudeAndLatitude(*longlatA)
    vec2 = spatialCoordinatesFromLongitudeAndLatitude(*longlatB)

    vec1 = np.array(vec1)
    vec2 = np.array(vec2)
    vec1 = vec1 / np.linalg.norm(vec1)
    vec2 = vec2 / np.linalg.norm(vec2)

    middle = vec1 + vec2
    middlevec = middle / np.linalg.norm(middle)

    crossprod = np.cross(vec1, vec2)
    crossvec = crossprod / np.linalg.norm(crossprod)

    #  Determines handedness / puts them in the center
    # thirdvec = np.cross(crossvec, middlevec)
    # thirdvec = thirdvec / np.linalg.norm(thirdvec)

    #  diffvec
    diffvec = vec2 - vec1
    diffvec = diffvec / np.linalg.norm(diffvec)

    rotation = np.matrix([middlevec, diffvec, crossvec])

    return(rotation.T)


def eulerAxisAngleFromRotationMatrix(R):
    """
    Returns a tuple, (theta, v)
    """
    theta = np.arccos(0.5*(R[0,0] + R[1,1,] + R[2,2] - 1))

    v1 = R[2, 1] - R[1, 2]
    v2 = R[0, 2] - R[2, 0]
    v3 = R[1, 0] - R[0, 1]

    vec = np.array([v1, v2, v3]) / (2.0 * np.sin(theta))

    return(theta, vec)


def quaternionFromMatrix(R):
    """
    Returns a list [qi, qj, qk, qr]
    """
    qr = 0.5 * np.sqrt(1 + np.trace(R))
    
    v1 = R[2, 1] - R[1, 2]
    v2 = R[0, 2] - R[2, 0]
    v3 = R[1, 0] - R[0, 1]

    qi, qj, qk = [v / 4.0*qr for v in [v1, v2, v3]]

    return [qi, qj, qk, qr]
    
