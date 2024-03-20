SELECT uuid, name, n_instr, n_branches, transmission_requirements_indirect_regs, transmission_expr, transmission_range_window, base_expr, secret_address_expr, branches, constraints, branch_requirements
FROM
all_gadgets
WHERE
-- The transmission depends only on RDI
all_requirements LIKE "%'regs': ['<BV64 rdi>']%" 
-- Branches depend only on RDI
-- AND branch_requirements LIKE "%'regs': ['<BV64 rdi>']%"
-- Function is reachable
AND name in reachable
-- Function is a syscall handler
AND name LIKE "%__x64_sys_%"
-- Granularity of control of the transmission address is 1 bit
AND transmission_range_stride = 1
ORDER BY CAST(n_instr AS INT)
;