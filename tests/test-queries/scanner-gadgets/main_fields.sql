SELECT
    name,
    address,
    pc,
    secret_load_pc,
    transmitter,
    n_instr,
    n_dependent_loads,
    contains_spec_stop,
    n_branches,
    branch_control_type,
    cmove_control_type
    bbls
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
