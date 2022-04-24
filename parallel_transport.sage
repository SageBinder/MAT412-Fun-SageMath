# Returns (E, F, G)
def compute_FFF(X_u, X_v):
    return (X_u.inner_product(X_u), X_u.inner_product(X_v), X_v.inner_product(X_v))

# Variable names are tricky here since (u, v) can be both the independent variables of X,
# as well as the dependent variables for the curve in the uv plane.
# In this function, we use X_1 and X_2 as the independent variables for X,
# and u and v as the dependent variables for the curve in the uv-plane.
# 
# The variables E_, F_, and G_ are given in terms of X_1 and X_2,
# but for computing the christoffel symbols,
# we want E, F, and G in terms of t.
# Hence, we substitute u and v for X_1 and X_2 respectively by using .subs(X_1 == u, X_2 == v).
def compute_christoffel(X_1, X_2, u, v, E_, F_, G_):
    E_u = diff(E_, X_1).subs(X_1 == u, X_2 == v)
    E_v = diff(E_, X_2).subs(X_1 == u, X_2 == v)
    F_u = diff(F_, X_1).subs(X_1 == u, X_2 == v)
    F_v = diff(F_, X_2).subs(X_1 == u, X_2 == v)
    G_u = diff(G_, X_1).subs(X_1 == u, X_2 == v)
    G_v = diff(G_, X_2).subs(X_1 == u, X_2 == v)

    E = E_.subs(X_1 == u, X_2 == v)
    F = F_.subs(X_1 == u, X_2 == v)
    G = G_.subs(X_1 == u, X_2 == v)
    
    C111 = var('C111')
    C121 = var('C121')
    C221 = var('C221')
    C112 = var('C112')
    C122 = var('C122')
    C222 = var('C222')
    
    eqn_11 = C111 * E + C112 * F == 1/2 * E_u
    eqn_12 = C111 * F + C112 * G == F_u - 1/2 * E_v
    
    eqn_21 = C121 * E + C122 * F == 1/2 * E_v
    eqn_22 = C121 * F + C122 * G == 1/2 * G_u
    
    eqn_31 = C221 * E + C222 * F == F_v - 1/2 * G_u
    eqn_32 = C221 * F + C222 * G == 1/2 * G_v
    
    C_sol_1 = solve([eqn_11, eqn_12], C111, C112)
    C_sol_2 = solve([eqn_21, eqn_22], C121, C122)
    C_sol_3 = solve([eqn_31, eqn_32], C221, C222)
    
    # We substitute the solutions for the Christoffel symbols into the Cijk to be returned.
    C111 = C111.subs(C_sol_1[0])
    C112 = C112.subs(C_sol_1[0])
    C121 = C121.subs(C_sol_2[0])
    C122 = C122.subs(C_sol_2[0])
    C221 = C221.subs(C_sol_3[0])
    C222 = C222.subs(C_sol_3[0])

    return (C111, C112, C121, C122, C221, C222)


# parallel_transport function
# Variables:

# X
# Parametrization of the surface in terms of X_1 and X_2

# X_1, X_2
# The function needs to know what variables X depends on,
# so we must give it the independent variables.

# u, v
# The parametrization of the curve in the uv-plane.

# T
# A 3-tuple (t, t_0, t_f) where t is the indepent variable of the curve,
# t_0 is the initial time of the curve,
# and t_f is the final time of the curve.

# initial_vec (Optional)
# Represents the initial vector to transport
# given in the basis {X_u, X_v} of TpS where p = X(u(t_0), v(t_0)).
# If None, the function defaults to the initial velocity of the curve.

# step (Optional)
# Step size given to SageMath's desolve_system_rk4 function for finding the
# numerical solution to the parallel transport differential equations.

# initial_vec_length (Optional)
# The function scales the initial vector to transport so that it has a length
# given by initial_vec_length.
# If None, the function does not scale the initial vector.
def parallel_transport(X, X_1, X_2, u, v, T, initial_vec=None, step=0.1, initial_vec_length=None):
    t = T[0]
    t_0 = T[1]
    t_f = T[2]

    X_u = diff(X, X_1)
    X_v = diff(X, X_2)
    
    E, F, G = compute_FFF(X_u, X_v)
    
    C111, C112, C121, C122, C221, C222 = compute_christoffel(X_1, X_2, u, v, E, F, G)
    
    a = var('a')
    b = var('b')
    
    v_t = diff(v, t)
    u_t = diff(u, t)
    
    diffeq_a = -(C111 * u_t + C121 * v_t) * a - (C121 * u_t + C221 * v_t) * b
    diffeq_b = -(C112 * u_t + C122 * v_t) * a - (C122 * u_t + C222 * v_t) * b
    
    if initial_vec == None:
        initial_vec = (u_t(t_0), v_t(t_0))

    if initial_vec_length is not None:
        initial_vec_on_surface = X_u(u(t_0), v(t_0)) * initial_vec[0] + X_v(u(t_0), v(t_0)) * initial_vec[1]
        length = initial_vec_on_surface.norm()
        initial_vec = ((initial_vec[0] / length) * initial_vec_length, (initial_vec[1] / length) * initial_vec_length)

    P = desolve_system_rk4([diffeq_a, diffeq_b], [a, b], ics=[t_0,initial_vec[0],initial_vec[1]], ivar=t, end_points=t_f, step=step)
    return P