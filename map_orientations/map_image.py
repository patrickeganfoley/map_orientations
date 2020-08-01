import numpy as np
from imageio import imread


class MapImage(object):


    def __init__(self, map_image_path, rotation, in_projection, out_projection):
        self.map_image_path = map_image_path
        self.image = imread(map_image_path)
        self.rotation = rotation
        self.ny = self.image.shape[0]
        self.nx = self.image.shape[1]
        self.in_projection = in_projection
        self.out_projection = out_projection


    def set_grid(self):
        xs, ys = np.meshgrid(np.arange(0, self.nx), np.arange(0, self.ny))
        self.xs = xs.flatten().astype(float)
        self.ys = ys.flatten().astype(float)


    def set_longitude_latitude(self):

        def longitudeAndLatitudeFromGPPixel(x, y, nx, ny):
            longitude = x * (2.0 * np.pi / float(nx)) - np.pi
            latitude = np.arcsin(2.0 * ((y / ny) - (0.5)))
            return longitude, latitude
        
        
        def longitudeAndLatitudeFromPCPixel(x, y, nx, ny):
            longitude = 2 * np.pi * ((x / float(nx)) - 0.5)
            latitude = - (np.pi * ((y / float(ny)) - 0.5))
            return longitude, latitude

        if self.in_projection == 'platecarre':
            self.longs, self.lats = longitudeAndLatitudeFromPCPixel(self.xs, self.ys, self.nx, self.ny)
        elif self.in_projection == 'gallpeters':
            self.longs, self.lats = longitudeAndLatitudeFromGPPixel(self.xs, self.ys, self.nx, self.ny)



    def set_new_longitude_latitude(self):
        # 70% of runtime
        
        def spatialCoordinatesFromLongitudeAndLatitude(longitude, latitude):
            x = np.cos(longitude) * np.cos(latitude)
            y = np.sin(longitude) * np.cos(latitude)
            z = np.sin(latitude)
            return x, y, z


        def rotationFromXYZ(angle_x, angle_y, angle_z):
            r_x = rotationMatrix(np.array([1.0, 0.0, 0.0]), angle_x)
            r_y = rotationMatrix(np.array([0.0, 1.0, 0.0]), angle_y)
            r_z = rotationMatrix(np.array([0.0, 0.0, 1.0]), angle_z)

            return np.dot(np.dot(r_x, r_y), r_z)


        def rotationMatrix(axis_vector, angle):
            axis_vector = axis_vector / np.sqrt(sum(axis_vector**2))
            (x, y, z) = axis_vector

            tensor_product_matrix = np.matrix([
                [x**2, x * y, x * z],
                [x * y, y**2, y * z],
                [x * z, y * z, z**2]
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


        def flip_longitudes(longitude):
            inds = np.greater(longitude, np.pi)
            longitude = longitude - 2 * np.pi * inds
            return longitude


        def longitudeAndLatitudeFromSpatialCoordinates(xxs, yys, zzs):
            latitude = np.arcsin(zzs)
            longitude = np.arctan2(yys, xxs)
            longitude = flip_longitudes(longitude)
            return longitude, latitude

        x, y, z = self.rotation
        xxs, yys, zzs = spatialCoordinatesFromLongitudeAndLatitude(self.longs, self.lats)
        rot_mat = rotationFromXYZ(float(x), float(y), float(z))
        new_xxyyzz = np.dot(rot_mat, np.array([xxs, yys, zzs]))
        new_xxs = np.squeeze(np.array(new_xxyyzz[0, :]))
        new_yys = np.squeeze(np.array(new_xxyyzz[1, :]))
        new_zzs = np.squeeze(np.array(new_xxyyzz[2, :]))
        
        self.new_longs, self.new_lats = longitudeAndLatitudeFromSpatialCoordinates(new_xxs, new_yys, new_zzs)


    def set_new_grid(self):

        def gall_peters_pixels(longitude, latitude, nx, ny):
            u = nx * (0.5 + (longitude / (2 * np.pi)))
            v = (ny / 2) * (np.sin(latitude) + 1.0)

            u = u.astype(int)
            v = v.astype(int)

            u[u == nx] = nx - 1
            v[v == ny] = 0

            return u, v


        def pixel_for_plate_carre(longitude, latitude, nx, ny):

            u = nx * (0.5 + (longitude / (2 * np.pi)))
            v = - (ny * (0.5 + (latitude / np.pi)))

            u = u.astype(int)
            v = v.astype(int)

            u[u == nx] = nx - 1
            v[v == ny] = ny - 1

            return u, v


        if self.out_projection == 'platecarre':
            self.new_xs, self.new_ys = pixel_for_plate_carre(self.new_longs, self.new_lats, self.nx, self.ny)
        elif self.out_projection == 'gallpeters':
            self.new_xs, self.new_ys = gall_peters_pixels(self.new_longs, self.new_lats, self.nx, self.ny)

        self.new_xs.shape = (self.ny, self.nx)
        self.new_ys.shape = (self.ny, self.nx)


    def make_new_map(self):
        self.new_map = np.zeros(dtype=self.image.dtype, shape=self.image.shape)
        self.new_map[:, :, 0] = self.image[self.new_ys, self.new_xs, 0]
        self.new_map[:, :, 1] = self.image[self.new_ys, self.new_xs, 1]
        self.new_map[:, :, 2] = self.image[self.new_ys, self.new_xs, 2]

