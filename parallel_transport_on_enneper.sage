import os, sys

## Hack to import custom Sage scripts
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

# SageMath has a built-in parametrization for Enneper's surface
enneper = surfaces.Enneper()

# Try messing around with the parametrization for the curve!
t = var('t')
c_1(t) = t
c_2(t) = t^2
t_0 = -sqrt(3)
t_f = sqrt(3)

u = var('u')
v = var('v')
X(u, v) = (enneper.equation[0], enneper.equation[1], enneper.equation[2])
print(X)

X_u = diff(X, u)
X_v = diff(X, v)

P = PT(X, u, v, c_1, c_2, (t, t_0, t_f), step=0.01, initial_vec_length=1)

X_plot = parametric_plot3d(X(u, v), (u, -3, 3), (v, -3, 3), frame=False,axes=False,color='purple',opacity=0.5)
C_plot = parametric_plot3d(X(c_1(t), c_2(t)), (t, t_0, t_f), frame=False, Axes=False,color='blue',opacity=1,thickness=3)

num_points = len(P)
num_to_plot = 30
period = int(num_points / num_to_plot)
vectors = []
for ti,a,b in P[::period]:
    vec = (scale(a, X_u(c_1(ti), c_2(ti))) + scale(b, X_v(c_1(ti), c_2(ti))))
    vec = scale(0.5, vec)
    vectors.append(arrow(X(c_1(ti), c_2(ti)), X(c_1(ti), c_2(ti)) + vec))
  

save_dir = "./parallel_transport_on_enneper/"

if not os.path.exists(save_dir):
    os.makedirs(save_dir)
    print('Creating directory ' + save_dir)

output = X_plot + sum(vectors) + C_plot
output.save(os.path.join(save_dir, "enneper_t_and_t2_still.html"), online=True)

print("before animate")
a = animate([X_plot + sum(vectors[:i+1]) + C_plot for i in range(len(vectors))])
print("after animate,  before save")
a.save(os.path.join(save_dir, "enneper_t_and_t2_anim.html"), online=True, show_path=True)