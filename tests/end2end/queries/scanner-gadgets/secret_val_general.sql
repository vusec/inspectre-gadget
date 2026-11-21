SELECT
    pc,
    secret_val_expr,
    secret_val_size,
    secret_val_branches,
    secret_val_constraints,
    secret_val_requirements_regs,
    secret_val_requirements_indirect_regs,
    secret_val_requirements_direct_regs,
    secret_val_requirements_mem,
    secret_val_requirements_const_mem,
    secret_val_control,
    secret_val_n_dependent_loads
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
