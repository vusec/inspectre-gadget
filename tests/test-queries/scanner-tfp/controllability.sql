SELECT
    pc,
    controlled,
    uncontrolled,
    unmodified,
    secrets
FROM
    tfps
order by pc, expr, constraints, branches
