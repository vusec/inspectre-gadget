SELECT
    pc,
    direct_dependent_base_expr,
    indirect_dependent_base_expr,
    base_control_type,
    base_control_w_constraints,
    base_control_w_branches_and_constraints
FROM
    gadgets
order by n_instr, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
