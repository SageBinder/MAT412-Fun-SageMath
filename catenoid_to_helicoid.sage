import numpy as np
import os, sys

pi = RR.pi()

# Produces catenoid/helicoid plot at the given theta
def transformation_plot(X, theta, urange=(-pi, pi), vrange=(-1, 1)):
    return ParametrizedSurface3D(X(u, v, theta), (u, v)).plot(urange, vrange, opacity=1)


# Produces plots for the lines of curvature
def lines_of_curvature_plots(X, theta, urange=(-pi, pi, 20), vrange=(-1, 1, 20), color='black', thickness=3):
    lines = []
    
    for ui in np.linspace(urange[0], urange[1], urange[2]):
        v = var('v')
        lines.append(parametric_plot3d(X(ui, v, theta), (v, vrange[0], vrange[1]), color=color, thickness=thickness))
    for vi in np.linspace(vrange[0], vrange[1], vrange[2]):
        u = var('u')
        lines.append(parametric_plot3d(X(u, vi, theta), (u, urange[0], urange[1]), color=color, thickness=thickness))
    return lines


# Combines plots for the surface, lines of curvature, and directrix/curve of striction
def get_total_plot(X, theta):
    return transformation_plot(X, theta) \
        + parametric_plot3d(X(u, 0, theta), (u, -pi, pi), color='red', thickness=3) \
        + sum(lines_of_curvature_plots(X, theta))


u = var('u')
v = var('v')

x(u, v, theta) = cos(theta) * sinh(v) * sin(u) + sin(theta) * cosh(v) * cos(u)
y(u, v, theta) = -cos(theta) * sinh(v) * cos(u) + sin(theta) * cosh(v) * sin(u)
z(u, v, theta) = u * cos(theta) + v * sin(theta)
X(u, v, theta) = (x(u, v, theta), y(u, v, theta), z(u, v, theta))

save_dir = "./catenoid_to_helicoid/"
if not os.path.exists(save_dir):
    os.makedirs(save_dir)
    print('Creating directory ' + save_dir)

# If the animation is too large for your computer to run,
# replace the 100 in the np.linspace() call with a smaller number.
a = animate([get_total_plot(X, theta) for theta in np.linspace(-pi/2, 3*pi/2, 100)])
a.save(os.path.join(save_dir, 'cat_to_hel_with_grid_thick_lines.html'), online=True, show_path=True)
