import numpy as np

pi = RR.pi()

x(z, x_0, y_0) = y_0 * cosh((z - x_0)/y_0)
X(theta, z, x_0, y_0) = (cos(theta) * x(z, x_0, y_0), sin(theta) * x(z, x_0, y_0), z)

def get_surface(X, x_0, y_0, max_r):
    def condition(x, y, z):
        return bool(sqrt(x^2 + y^2) <= max_r)

    max_z = solve([sqrt(X(0, z, x_0, y_0)[0]^2 + X(0, z, x_0, y_0)[1]^2) == max_r], z)
    print(max_z)

    P = parametric_plot3d(X(theta, z, x_0, y_0), (theta, 0, 2*pi), (z, -z.subs(max_z), z.subs(max_z)))
    R = P.add_condition(condition)

    return R

# surface = get_surface(X, 1, 1, 10)
# surface.save("./stretching_catenoid/test.html", online=True, show_path=True)

max_r = 8

a = animate([get_surface(X, 0, y_0, max_r) for y_0 in np.linspace(1, 5, 50)])
a.save(f"./stretching_catenoid/stretching_catenoid_r={max_r}_anim_1.html", online=True, show_path=True)