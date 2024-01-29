SELECT
    pc,
    transmitted_secret_expr,
    transmitted_secret_size,
    transmitted_secret_branches,
    transmitted_secret_constraints,
    transmitted_secret_requirements_regs,
    transmitted_secret_requirements_indirect_regs,
    transmitted_secret_requirements_direct_regs,
    transmitted_secret_requirements_mem,
    transmitted_secret_requirements_const_mem,
    transmitted_secret_control,
    transmitted_secret_n_dependent_loads
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
