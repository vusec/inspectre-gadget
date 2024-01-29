SELECT
    pc,
    transmission_expr,
    transmission_size,
    transmission_branches,
    transmission_constraints,
    transmission_requirements_regs,
    transmission_requirements_indirect_regs,
    transmission_requirements_direct_regs,
    transmission_requirements_mem,
    transmission_requirements_const_mem,
    transmission_control,
    transmission_n_dependent_loads
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
