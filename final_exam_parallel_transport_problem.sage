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
v,u = var('v', 'u')

# We need this epsilon since the parametrization is not defined at the poles,
# so we cannot start the curves at either pole
eps = 0.05

# This is the curve along which we transport,
# as given by the problem
c_1(t) = t
c_2(t) = pi/2 - t

# Natural parametrization of the sphere
X(u, v) = (sin(v) * cos(u), sin(v) * sin(u), cos(v))

# Calculating X_u and X_v,
# which we will need to plot the vector as it transports,
# since the parallel_transport function returns the vectors
# in the {X_u, X_v} basis at each TpS
X_u = diff(X, u)
X_v = diff(X, v)

# Running the parallel transport function.
# We let t range from (-pi/2 + eps) → (pi/2 + eps),
# since the surface is not defined when t = ±pi/2
P = PT(X, u, v, c_1, c_2, (t, -pi/2 + eps, pi/2 - eps), initial_vec=(1, 0), initial_vec_length=1)

X_plot = parametric_plot3d(X(u, v), (u, -pi, pi), (v, 0, pi), frame=False,axes=False,color='purple',opacity=1)
C_plot = parametric_plot3d(X(c_1(t), c_2(t)), (t, -pi/2, pi/2), frame=False, Axes=False,color='blue',opacity=1,thickness=3)

# print(P)

# We may not want to plot every vector given by the parallel transport solution.
# For example, if the step size is very small,
# there will be far too many vectors to plot.
# Hence, we use num_to_plot to control the number of vectors we plot along the curve.
num_to_plot = len(P)

num_points = len(P)
period = int(num_points / num_to_plot)
vectors = []
for ti,a,b in P[::period]:
    vec = (scale(a, X_u(c_1(ti), c_2(ti))) + scale(b, X_v(c_1(ti), c_2(ti))))
    vectors.append(arrow(X(c_1(ti), c_2(ti)), X(c_1(ti), c_2(ti)) + vec))
  

save_dir = "./final_exam_prob/"
if not os.path.exists(save_dir):
    os.makedirs(save_dir)
    print('Creating directory ' + save_dir)

output = X_plot + sum(vectors) + C_plot
output.save(os.path.join(save_dir, "final_exam_parallel_transport_problem_still.html"), online=True)

print("before animate")
# Creating an animation.
# If you want to show only a single vector at each frame,
# replace "sum(vectors[:i+1])" with "vectors[i]"
a = animate([X_plot + sum(vectors[:i+1]) + C_plot for i in range(len(vectors))])
print("after animate, now saving")
a.save(os.path.join(save_dir, "final_exam_parallel_transport_problem_anim.html"), online=True, show_path=True)