SELECT
    pc,
    constraints,
    requirements,
    branches
FROM
    tfps
order by pc, expr, constraints, branches
