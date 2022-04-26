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
# phi,theta = var('φ', 'θ')

# Parametrization for the curve in the uv-plane (or really the θφ-plane)
u_0(t) = 0
u_1(t) = pi/4
u_2(t) = pi/2
# u_3(t) = 3*pi/4
v(t) = t

a = 5
b = 1
X(theta, phi) = ((a + b * cos(theta)) * cos(phi), (a + b * cos(theta)) * sin(phi), b * sin(theta))
X_theta = diff(X, theta)
X_phi = diff(X, phi)

P0 = PT(X, theta, phi, u_0, v, (t, 0, 2 * pi), initial_vec_length=0.6)
P1 = PT(X, theta, phi, u_1, v, (t, 0, 2 * pi), initial_vec_length=0.6)
P2 = PT(X, theta, phi, u_2, v, (t, 0, 2 * pi), initial_vec_length=0.6)
# P3 = PT(X, theta, phi, u_3, v, (t, 0, 2 * pi), initial_vec_length=1)

X_plot = parametric_plot3d(X(theta, phi), (theta, 0, 2 * pi), (phi, 0, 2 * pi), frame=False,axes=False,color='purple',opacity=1)
C_0_plot = parametric_plot3d(X(u_0(t), v(t)), (t, 0, 2 * pi), frame=False, Axes=False, color='aliceblue', opacity=1, thickness=3)
C_1_plot = parametric_plot3d(X(u_1(t), v(t)), (t, 0, 2 * pi), frame=False, Axes=False, color='aliceblue', opacity=1, thickness=3)
C_2_plot = parametric_plot3d(X(u_2(t), v(t)), (t, 0, 2 * pi), frame=False, Axes=False, color='aliceblue', opacity=1, thickness=3)
# C_3_plot = parametric_plot3d(X(u_3(t), v(t)), (t, 0, 2 * pi), frame=False, Axes=False,color='blue',opacity=1)

def get_PT_vecs(P, u, num_to_plot=None, color='blue'):
    num_points = len(P)
    if num_to_plot is None:
        num_to_plot = num_points
    period = int(num_points / num_to_plot)
    vectors = []
    for ti,a,b in P[::period]:
        vec = (scale(a, X_theta(u(ti), v(ti))) + scale(b, X_phi(u(ti), v(ti))))
        vectors.append(arrow(X(u(ti), v(ti)), X(u(ti), v(ti)) + vec, color=color))

    return vectors
  
vecs_0 = get_PT_vecs(P0, u_0, 40, 'blue')
vecs_1 = get_PT_vecs(P1, u_1, 40, 'green')
vecs_2 = get_PT_vecs(P2, u_2, 40, 'red')
# vecs_3 = get_PT_vecs(P3, u_3, 40)

save_dir = "./parallel_transport_on_torus/"

if not os.path.exists(save_dir):
    os.makedirs(save_dir)
    print('Creating directory ' + save_dir)

output = X_plot + sum(vecs_0 + vecs_1 + vecs_2) + C_0_plot + C_1_plot + C_2_plot
output.save(os.path.join(save_dir, "PT_on_torus_still.html"), online=True)

print("before animate")
a = animate([X_plot + sum(vecs_0[:i+1] + vecs_1[:i+1] + vecs_2[:i+1]) + C_0_plot + C_1_plot + C_2_plot for i in range(min(len(vecs_0), len(vecs_1), len(vecs_2)))])
print("after animate,  before save")
a.save(os.path.join(save_dir, "PT_on_torus_anim.html"), online=True, show_path=True)