import numpy as np
import matplotlib.pyplot as plt
from imageio import imread, imwrite
from copy import deepcopy

import uuid
import imageio


def get_hemisphere(center, radius, base=cropped_blau):
    """Center is (x,y) pixels, radius is in pixels.
    Start from cropped."""
    cx, cy = center
    assert cx > radius
    assert cy > radius
    nxbase, nybase, _ = base.shape
    assert nxbase - cx > radius
    assert nybase - cy > radius
    square = deepcopy(base[
        (cx-radius):(cx+radius), (cy-radius):(cy+radius), :
    ])
    #  Need to make other pixels black.  Or maybe not.
    #  square is now shape r, r, 3
    npix = 2*radius + 1
    xs, ys = np.meshgrid(np.arange(0, npix-1), np.arange(0, npix-1))
    out_of_circle = (xs - (npix/2))**2 + (ys-(npix/2))**2 > radius**2
    square[xs[out_of_circle], ys[out_of_circle], :] = 0
    return square


def uv_to_st(u, v, radius=p_rad, debug=False):
    """Images are not arranged how I want.  This remaps them.

    They start (call this u, v) with It is (y, x) and the top left is 0,0.
    top left      -  0, 0
    top right     -  0, N
    bottom left   -  N, 0
    bottom right  -  N, N
    these  also go 0 to 2r, 0 to 2r.

    Maybe I should first turn it from p1, p2 to u,v where it's x, y
    and
      topleft     - 0, N
      topright    - N, N
      bottomleft  - 0, 0
      bottomright - N, 0
    should these be -r to r?

    pixels are [s, t, rgb]
    then x,y is [u, v, rgb]"""
    if debug:
        print ' in uv to st'
        print 'range of u is {} to {}'.format(min(u), max(u))
        print 'range of v is {} to {}'.format(min(v), max(v))

    s = v - radius
    t = radius - u
    if debug:
        print 'range of s is {} to {}'.format(min(s), max(s))
        print 'range of t is {} to {}'.format(min(t), max(t))

    return s, t


def st_to_uv(s, t, radius=p_rad, debug=False):
    """Images are not arranged how I want.  This remaps them.

    They start (call this u, v) with It is (y, x) and the top left is 0,0.
    top left      -  0, 0
    top right     -  0, N
    bottom left   -  N, 0
    bottom right  -  N, N

    Maybe I should first turn it from p1, p2 to u,v where it's x, y
    and
      topleft     - 0, N
      topright    - N, N
      bottomleft  - 0, 0
      bottomright - N, 0

    pixels are [s, t, rgb]
    then x,y is [u, v, rgb]

    really s,t are in [0, 2r].  u,v (closer to xy) are -r,r."""
    if debug:
        print ' in st to uv'
        print 'range of s is {} to {}'.format(min(s), max(s))
        print 'range of t is {} to {}'.format(min(t), max(t))
    # 12/28/18 - DO NOT CHANGE THESE.
    # Flipping the sign on the t and s will flip the output maps.
    u = radius + t  # neither should this
    v = radius - s  # ????  this should not work...  #removed it?
    if debug:
        print 'range of u is {} to {}'.format(min(u), max(u))
        print 'range of v is {} to {}'.format(min(v), max(v))

    return u, v


def st_to_xyz(s, t, NS, radius, debug=False):
    """Spatial coordinates on unit sphere from pixel values and
    map radius for a centered stereographic projection. Sterographic
    projection map is taken to go -r to r in pixels.

    u is -r to r,
    v is -r to r
    NS is -1 (western hemisphere or southern) or 1(eastern or northern)
    -r,-r is bottom left.

    NOTE:  Images are oriented kind of weird.
        It is (y, x) and the top left is 0,0.
    top left      -  0, 0
    top right     -  0, N
    bottom left   -  N, 0
    bottom right  -  N, N

    Maybe I should first turn it from p1, p2 to u,v where it's x, y
    and
      topleft     - 0, N
      topright    - N, N
      bottomleft  - 0, 0
      bottomright - N, 0
    """
    # assert all(s**2 + t**2 <= radius**2)
    assert all([ns in [-1, 1] for ns in NS])
    # is it this or inverse?
    if debug:
        print 'in st to xyz'
        print 'range of s and t are'
        print 's: {} to {}'.format(min(s), max(s))
        print 't: {} to {}'.format(min(t), max(t))

    x = s * 1.0 / radius
    y = t * 1.0 / radius
    pixnorm = x**2 + y**2

    #  Try instead rotating 3d.
    #  Also you need to be careful - is u,v like x,y or how does indexing work?
    #  I want it to be like x, y.
    #  is that ns on the z correct..?
    vx = -NS * 2*x / (1 + pixnorm)
    # Don't remove the - here.
    vy = -NS * 2*y / (1 + pixnorm)
    vz = (-NS * (-1 + pixnorm)) / (1 + pixnorm)
    if debug:
        print 'in st to xyz'
        print 'ranges of xyz are'
        print 'x: {} to {}'.format(min(vx), max(vx))
        print 'y: {} to {}'.format(min(vy), max(vy))
        print 'z: {} to {}'.format(min(vz), max(vz))

    return (vx, vy, vz)


def xyz_to_st(x, y, z, radius, debug=False):
    """Spatial coordinates on unit sphere from pixel values and
    map radius for a centered stereographic projection. Sterographic
    projection map is taken to go -r to r in pixels"""
    # renormalize
    xyznorm = np.sqrt(x**2 + y**2 + z**2)
    assert (xyznorm <= 1.00001).all()
    assert (xyznorm >= 0.9999).all()

    x /= xyznorm
    y /= xyznorm
    z /= xyznorm

    #  Choose Hemisphere
    NS = 2.0 * np.greater(z, 0.0) - 1.0
    absz = np.abs(z)
    assert (abs(NS) <= 1.0001).all()
    assert (abs(NS) >= 0.9999).all()

    s = (x / (1 + absz))
    t = (y / (1 + absz))
    s = np.round(s * radius)
    t = np.round(t * radius)

    if debug:
        print 'in xyz to st'
        print 'range of s: {} to {}'.format(np.min(s), np.max(s))
        print 'range of t: {} to {}'.format(np.min(t), np.max(t))

    # This is for the opposite hemisphere
    altS = -s
    # change for 9
    # IT WORKED!!
    altT = t

    # altV = radius - v
    s = np.greater(NS, 0) * s + np.greater(0, NS)*altS
    # change for 10
    # (and 11.  changing back now.)
    # want it positive.
    t = (np.greater(NS, 0) * t + np.greater(0, NS)*altT)

    # trying to flip the eastern / northern / right hemisphere.
    # (nah.  don't flip both s and t.  doesn't work.)
    # Let's try just t first.
    # just t first does not work.  try just s.
    # t = - NS * t
    # s = - NS * s
    # Nope.  just s also does not work.
    # now let's try flipping without the ns??
    t = -t
    # just flipping t and negative t is ALMOST ok.
    # let me try a few more.  It ALMOST works except the western
    # hemisphere has the y axis flipped.
    # gif 17 works.

    if debug:
        print 'in xyz to st after alts'
        print 'range of s: {} to {}'.format(np.min(s), np.max(s))
        print 'range of t: {} to {}'.format(np.min(t), np.max(t))

    #  Outputs need to be indices, so NS should be
    #  0 for western, 1 for eastern.
    return (s, t, NS)


def randomRotation():
    rand_vec = np.random.randn(3, 1).flatten()

    vec_norm = np.linalg.norm(rand_vec)
    rand_vec = rand_vec / vec_norm
    return rotationMatrix(rand_vec, vec_norm)


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


def generate_img(
        western, eastern,
        n_rad, rot_mat=np.eye(3),
        prefix='',
        debug=False, writeframe=False
):
    # Start with u, v
    assert western.shape == eastern.shape
    assert n_rad == western.shape[0] / 2

    full_array = np.array([western, eastern])
    new_full_array = deepcopy(full_array)
    us, vs = np.meshgrid(np.arange(-n_rad, n_rad), np.arange(-n_rad, n_rad))
    in_circle = [
        u**2 + v**2 < n_rad**2
        for u, v in zip(us, vs)
    ]
    us = us[in_circle]
    vs = vs[in_circle]

    # us and vs now go from -r to r such that u**2 + v**2 < radius
    us = us + n_rad
    vs = vs + n_rad
    # now they go from 0 to 2r.  Note they don't cover the full square.
    # they are NOT the same shape as western / eastern.

    n_pixels_in_hemisphere = len(us)
    # for western AND eastern
    all_us = np.tile(us, 2)
    all_vs = np.tile(vs, 2)
    all_NSs = np.repeat(np.array([-1, 1]), n_pixels_in_hemisphere)
    all_NSs01 = (0.5 * (all_NSs + 1.0)).astype(int)

    # Should I regenerate the us and vs? 
    arr_s, arr_t = uv_to_st(all_us, all_vs, radius=n_rad, debug=debug)
    
    xyzs = st_to_xyz(
        arr_s, arr_t, all_NSs, 
        radius=n_rad,
        debug=debug
    )
    nxs, nys, nzs = xyzs
    
    new_xxyyzz = np.dot(rot_mat, np.array([nxs, nys, nzs]))
    nxs = np.squeeze(np.array(new_xxyyzz[0, :]))
    nys = np.squeeze(np.array(new_xxyyzz[1, :]))
    nzs = np.squeeze(np.array(new_xxyyzz[2, :]))

    
    newSs, newTs, newNSs = xyz_to_st(
        nxs, nys, nzs, 
        radius=n_rad,
        debug=debug
    ) 
    pixels_in_new_north = newNSs == 1


    newUs, newVs = st_to_uv(newSs, newTs, radius=n_rad, debug=debug)

    new_us_indices = (newUs - 1).astype(int)
    new_vs_indices = (newVs - 1).astype(int)
    new_nss_indices = (0.5 + 0.5*newNSs).astype(int)

    new_full_array[all_NSs01.astype(int), all_us.astype(int), all_vs.astype(int), 0] = full_array[new_nss_indices, new_us_indices, new_vs_indices, 0]
    new_full_array[all_NSs01.astype(int), all_us.astype(int), all_vs.astype(int), 1] = full_array[new_nss_indices, new_us_indices, new_vs_indices, 1]
    new_full_array[all_NSs01.astype(int), all_us.astype(int), all_vs.astype(int), 2] = full_array[new_nss_indices, new_us_indices, new_vs_indices, 2]

    new_western = new_full_array[0, :, :, :]
    new_eastern = new_full_array[1, :, :, :]
    
    # I do not understand why, but the y axis on the western gets flipped somewhere.
    # this is for gif 19
    #. wrong axis.  1 doesn't work.  try 2. 
    #. lol.  2 makes it blue.  try 0.
    new_western = np.flip(new_western, axis=0)

    if writeframe:
        imwrite("broken_blauau_attempt_" + prefix + str(uuid.uuid4()) + ".jpg", new_western)
        imwrite("broken_blauau_attempt_" + prefix + str(uuid.uuid4()) + ".jpg", new_eastern)
    


    if debug:
        print 'Trying to plot now'
        w=4
        h=4
        fig=plt.figure(figsize=(12, 12))
        columns = 2
        rows = 1        
        fig.add_subplot(rows, columns, 1)
        plt.imshow(new_western)
        fig.add_subplot(rows, columns, 2)
        plt.imshow(new_eastern)
        plt.show()
        
    return np.concatenate((new_western, new_eastern), axis=1)


def constant_acc_curve(n_steps):
    """Provides a constant accelaration / constant deceleration path from 0 to 1."""
    velocity = 0.0
    position = 0.0
    positions = [0.0]
    delta_v = 1.0 / (1.0 * n_steps)
    
    # What's the required accel to get it to go from 0 to 1 in n steps?
    for step_i in np.arange(n_steps):
        position += velocity
        
        if ((1.0*step_i) / (1.0*n_steps)) < 0.5:
            velocity += delta_v
        elif ((1.0*step_i) / (1.0*n_steps)) > 0.5:
            velocity -= delta_v
        
        positions += [position]
        
    # OK, whatever, I'll just divide by max rather than figure out constant.
    return [position / max(positions) for position in positions]


def make_gif(
    filename,    
    western, eastern,
    radius,
    rot_mat_axis,
    n_images=50,
    seconds = 8.0    
):
    """Make a smooth gif doing a full rotation."""
    make_transition_gif(
        filename,    
        western, eastern,
        radius,
        rot_mat_axis,
        rot_mat_angle = 2.0 * np.pi,
        n_images = n_images,
        seconds = seconds
    )
    
    
def make_repeating_gif(
    filename,        
    western, eastern,
    radius,
    rot_mat_axis,
    n_images=50,
    seconds = 8.0    
):
    """Make a repeating gif showing a rotation at constant speed"""
    angles = np.linspace(0, 2*np.pi, n_images)
    
    with imageio.get_writer(filename, mode='I', fps = ((1.0*n_images) / seconds)) as writer:
        for angle in angles:
            rot_mat = rotationMatrix(axis_vector=rot_mat_axis, angle=angle)
            image = generate_img(
                western=western, eastern=eastern, 
                n_rad=radius, 
                rot_mat=rot_mat
            )
            writer.append_data(image)    
    
      


def make_transition_gif(
    filename,    
    western, eastern,
    radius,
    rot_mat_axis,
    rot_mat_angle,
    n_images=10,
    seconds = 8.0
):
    """For one rotation matrix, make a gif going from standard map to
    a different position."""
    angles = [rot_mat_angle * np.pi * angle for angle in constant_acc_curve(n_images)]
    
    with imageio.get_writer(filename, mode='I', fps = ((1.0*n_images) / seconds)) as writer:
        for angle in angles:
            rot_mat = rotationMatrix(axis_vector=rot_mat_axis, angle=angle)
            image = generate_img(
                western=western, eastern=eastern, 
                n_rad=radius, 
                rot_mat=rot_mat
            )
            writer.append_data(image)
            
def make_back_and_forth_gif(
    filename,    
    western, eastern,
    radius,
    rot_mat_axis,
    rot_mat_angle,
    n_images=10,
    seconds = 8.0
):
    """For one rotation matrix, make a gif going from standard map to
    a different position and back."""
    angles = [rot_mat_angle * np.pi * angle for angle in constant_acc_curve(n_images)]
    
    

    with imageio.get_writer(filename, mode='I', fps = ((1.0*n_images) / seconds)) as writer:
        for angle in angles:
            rot_mat = rotationMatrix(axis_vector=rot_mat_axis, angle=angle)
            image = generate_img(
                western=western, eastern=eastern, 
                n_rad=radius, 
                rot_mat=rot_mat
            )
            writer.append_data(image)
