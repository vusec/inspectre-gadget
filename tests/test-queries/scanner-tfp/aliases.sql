SELECT
    pc,
    aliasing,
    aliases
FROM
    tfps
order by n_instr, expr, constraints, branches
