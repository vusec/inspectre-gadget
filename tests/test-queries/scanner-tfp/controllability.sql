SELECT
    pc,
    controlled,
    uncontrolled,
    unmodified
FROM
    tfps
order by n_instr, expr, constraints, branches
