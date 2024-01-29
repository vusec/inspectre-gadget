SELECT
    pc,
    name,
    address,
    reg,
    expr,
    n_instr,
    n_dependent_loads,
    n_branches,
    contains_spec_stop,
    bbls
FROM
    tfps
order by pc, expr, constraints, branches
