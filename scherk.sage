import numpy as np

t = var('t')
u = var('u')
v = var('v')
c = var('c')

pi = RR.pi()

X(u, v, c) = (u, v, 1/c * log(cos(v)/cos(u)))
def make_plot(c, urange=(0,4*pi), vrange=(0,4*pi)):
    return parametric_plot3d(X(u, v, c), (u, urange[0], urange[1]), (v, vrange[0], vrange[1]), plot_points=[50, 50])

a = animate([make_plot(c) for c in np.append(np.linspace(1, 5, 50), np.flip(np.linspace(1, 5, 50)))])
a.save("./scherk/scherk_anim_varying_c_HQ.html", online=True, show_path=True)


# Lots of different ways to restrict the plot of the surface to get nice looking results.

# def height_condition(x, y, z):
#     return bool(-2 < z < 2)

# c = 1
# plot = make_plot(c, (-pi/2, pi/2), (-pi/2, pi/2))
# plot.save("./scherk/scherk_still.html", online=True)
# restricted_plot = plot.add_condition(height_condition)
# restricted_plot.save("./scherk/scherk_still_restricted.html", online=True)