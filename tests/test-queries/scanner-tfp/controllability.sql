SELECT
    pc,
    controlled,
    uncontrolled,
    unmodified
FROM
    tfps
order by pc, expr, constraints, branches
