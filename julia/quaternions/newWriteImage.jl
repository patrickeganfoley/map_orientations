using Debug


@debug function mapforquaternion(q::quaternion, originalimage, newname)

    oldglobe = imread(originalimage)
    newglobe = imread(originalimage)

    println("Read in the image ...")
    
    (nc, nx, ny) = size(oldglobe)
    r = nx / (2 * pi)              #  r is the radius of the globe.
                                   #  In pixels in this case.

    γ = ny * pi / nx               #  gamma is the longitude from the
                                   #  central meridian in degrees.
                                   #  No.  I don't know what gamma is
                                   #  here.  Or why.  I think it might
                                   #  be the stretch factor, which is
                                   #  usually 2.  Can't tell.

    imagesize = (nx, ny)

    assignablepixindex = 1
    
    # don't loop.

    ys = 1:ny
    xs = 1:nx

    φs = asin( ( 2 .* ys / ny ) .- 1)

    # Loop... xs?
    
    λs = 2 * pi .* ( ( xs ./ nx) .- (1/2) )

    #  Ah.  the roatebyq thing is tough now.
    newlocations = [ rotateByQuaternion(SphCoords(φ, λ), q) for φ in φs, λ in λs ]
    
    @bp






end


#  Test. 