SELECT
    pc,
    controlled_sufficiently_w_branches,
    controlled_fully_w_branches,
    controlled_sufficiently_indirect_w_branches,
    controlled_fully_indirect_w_branches,
    controlled_sufficiently_all_w_branches,
    controlled_fully_all_w_branches
FROM
    tfps
order by pc, expr, constraints, branches
