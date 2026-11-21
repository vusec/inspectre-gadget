SELECT
    pc,
    constraints,
    requirements_regs,
    requirements_indirect_regs,
    requirements_direct_regs,
    requirements_mem,
    requirements_const_mem,
    branches
FROM
    tfps
order by pc, expr, constraints, branches
