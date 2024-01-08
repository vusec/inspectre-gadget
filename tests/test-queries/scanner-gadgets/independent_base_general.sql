SELECT
    pc,
    independent_base_expr,
    independent_base_size,
    independent_base_branches,
    independent_base_constraints,
    independent_base_requirements_regs,
    independent_base_requirements_indirect_regs,
    independent_base_requirements_direct_regs,
    independent_base_requirements_mem,
    independent_base_requirements_const_mem,
    independent_base_control,
    independent_base_n_dependent_loads
FROM
    gadgets
order by n_instr, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
