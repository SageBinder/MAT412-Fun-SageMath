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
X(theta, phi) = (sin(phi) * cos(theta), sin(phi) * sin(theta), cos(phi))
X_theta = diff(X, theta)
X_phi = diff(X, phi)

# Like with the parallel transport on the final exam problem,
# we need this epsilon to deal with the fact that the parametrization does not
# cover the poles of the sphere.
epsilon = 0.01
step=0.01

# 'angle' represents the change in longitude
# 'meridian' represents the change in latitude (starting from the north pole)
# To get the class logo, set both variables to pi/2
# (Recommend changing the save file name at the end of the script to match angle/meridian)
angle = 5*pi/6
meridian = 3*pi/4

u_1(t) = 0
v_1(t) = t

u_2(t) = t
v_2(t) = meridian

u_3(t) = angle
v_3(t) = t

# For parallel transport along piecewise curves,
# we simply take the final vector from each transport and give it as the
# initial vector for the next transport
print("Doing parallel transport along the first curve...")
PT_1 = PT(X, theta, phi, u_1, v_1, (t, epsilon, meridian), (50, 0), step)
final_PT_1 = PT_1[-1]

print("Doing parallel transport along the second curve...")
PT_2 = PT(X, theta, phi, u_2, v_2, (t, 0, angle), (final_PT_1[1], final_PT_1[2]), step)
final_PT_2 = PT_2[-1]

print("Doing parallel transport along the third curve...")
PT_3 = PT(X, theta, phi, u_3, v_3, (t, meridian, 0), (final_PT_2[1], final_PT_2[2]), step)

X_plot = parametric_plot3d(X(theta, phi), (theta, 0, 2 * pi), (phi, 0, pi), frame=False,axes=False,color='purple',opacity=1)
vectors = []

count = -1
num_points = len(PT_1 + PT_2 + PT_3)
num_to_plot = 15

for ti,a,b in PT_1[::int(len(PT_1) / num_to_plot)]:
    vec = (scale(a, X_theta(u_1(ti), v_1(ti))) + scale(b, X_phi(u_1(ti), v_1(ti))))
    vectors.append(arrow(X(u_1(ti), v_1(ti)), X(u_1(ti), v_1(ti)) + vec))
    
for ti,a,b in PT_2[::int(len(PT_2) / num_to_plot)]:
    vec = (scale(a, X_theta(u_2(ti), v_2(ti))) + scale(b, X_phi(u_2(ti), v_2(ti))))
    vectors.append(arrow(X(u_2(ti), v_2(ti)), X(u_2(ti), v_2(ti)) + vec))
    
for ti,a,b in reversed(PT_3[::int(len(PT_3) / num_to_plot)]):
    vec = (scale(a, X_theta(u_3(ti), v_3(ti))) + scale(b, X_phi(u_3(ti), v_3(ti))))
    vectors.append(arrow(X(u_3(ti), v_3(ti)), X(u_3(ti), v_3(ti)) + vec))

print(vectors)

C_1_plot = parametric_plot3d(X(u_1(t), v_1(t)), (t, 0, meridian), frame=False, axes=False, color='blue', opacity=1)
C_2_plot = parametric_plot3d(X(u_2(t), v_2(t)), (t, 0, angle), frame=False, axes=False, color='blue', opacity=1)
C_3_plot = parametric_plot3d(X(u_3(t), v_3(t)), (t, 0, meridian), frame=False, axes=False, color='blue', opacity=1)

print("Before animate")
a = animate([X_plot + C_1_plot + C_2_plot + C_3_plot + sum(vectors[:i+1]) for i in range(len(vectors))])
print("After animate, saving now...")

save_dir = "./class_logo/"
if not os.path.exists(save_dir):
    os.makedirs(save_dir)
    print('Creating directory ' + save_dir)

# CHANGE FILE NAME IF YOU CHANGE ANGLE/MERIDIAN
a.save(os.path.join(save_dir, "class_logo_3pi_over_4_meridian_5pi_over_6_angle.html"), online=True, show_path=True) 