SELECT
    pc,
    constraints,
    requirements,
    branches
FROM
    tfps
order by n_instr, expr, constraints, branches
