SELECT
    pc,
    aliasing,
    aliases
FROM
    tfps
order by pc, expr, constraints, branches
