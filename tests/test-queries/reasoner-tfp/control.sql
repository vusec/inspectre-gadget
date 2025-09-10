SELECT
    pc,
    controlled_sufficiently,
    controlled_fully,
    controlled_sufficiently_indirect,
    controlled_fully_indirect,
    controlled_sufficiently_all,
    controlled_fully_all
FROM
    tfps
order by pc, expr, constraints, branches
