SELECT
    pc,
    base_expr,
    base_size,
    base_branches,
    base_constraints,
    base_requirements_regs,
    base_requirements_indirect_regs,
    base_requirements_direct_regs,
    base_requirements_mem,
    base_requirements_const_mem,
    base_control,
    base_n_dependent_loads
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
