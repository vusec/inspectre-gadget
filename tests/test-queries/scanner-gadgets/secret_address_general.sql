SELECT
    pc,
    secret_address_expr,
    secret_address_size,
    secret_address_branches,
    secret_address_constraints,
    secret_address_requirements_regs,
    secret_address_requirements_indirect_regs,
    secret_address_requirements_direct_regs,
    secret_address_requirements_mem,
    secret_address_requirements_const_mem,
    secret_address_control,
    secret_address_n_dependent_loads
FROM
    gadgets
order by n_instr, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
