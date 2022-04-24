import os, sys

# Hack to import custom Sage scripts
def my_import(module_name, func='*', import_as=None):
    import os
    os.system('sage --preparse ' + module_name + '.sage')
    os.system('mv ' + module_name + '.sage.py ' + module_name + '.py')

    from sage.misc.python import Python
    python = Python()
    python.eval('from ' + module_name + ' import ' + func + (' as ' + import_as) if import_as != None else '', globals())

my_import("parallel_transport", "parallel_transport", "PT")

pi = RR.pi()

def scale(a, v):
    return vector([a * x for x in v])

t = var('t')
phi,theta = var('φ', 'θ')

# Parametrization for the curve in the uv-plane (or really the θφ-plane)
u(t) = t
v(t) = pi/5

X(theta, phi) = (cos(theta) * cos(phi), sin(theta) * cos(phi), sin(phi))
X_theta = diff(X, theta)
X_phi = diff(X, phi)

P = PT(X, theta, phi, u, v, (t, 0, 2 * pi))

X_plot = parametric_plot3d(X(theta, phi), (theta, 0, 2 * pi), (phi, 0, 2 * pi), frame=False,axes=True,color='purple',opacity=1)
C_plot = parametric_plot3d(X(u(t), v(t)), (t, 0, 2 * pi), frame=False, Axes=False,color='blue',opacity=1)

num_points = len(P)
num_to_plot = len(P)
period = int(num_points / num_to_plot)
vectors = []
for ti,a,b in P[::period]:
    vec = (scale(a, X_theta(u(ti), v(ti))) + scale(b, X_phi(u(ti), v(ti))))
    vectors.append(arrow(X(u(ti), v(ti)), X(u(ti), v(ti)) + vec))
  

save_dir = "./parallel_transport_on_sphere/"

if not os.path.exists(save_dir):
    os.makedirs(save_dir)
    print('Creating directory ' + save_dir)

output = X_plot + sum(vectors) + C_plot
output.save(os.path.join(save_dir, "pi_over_5_initial_vec_tangent_still.html"), online=True)

print("before animate")
a = animate([X_plot + sum(vectors[:i+1]) + C_plot for i in range(len(vectors))])
print("after animate,  before save")
a.save(os.path.join(save_dir, "pi_over_5_initial_vec_tangent_animation.html"), online=True, show_path=True)