SELECT
    pc,
    rax_reg,
    rax_expr,
    rax_control,
    rax_branches,
    rax_constraints,
    rax_requirements,
    rax_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    rbx_reg,
    rbx_expr,
    rbx_control,
    rbx_branches,
    rbx_constraints,
    rbx_requirements,
    rbx_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    rcx_reg,
    rcx_expr,
    rcx_control,
    rcx_branches,
    rcx_constraints,
    rcx_requirements,
    rcx_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    rdx_reg,
    rdx_expr,
    rdx_control,
    rdx_branches,
    rdx_constraints,
    rdx_requirements,
    rdx_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    rsi_reg,
    rsi_expr,
    rsi_control,
    rsi_branches,
    rsi_constraints,
    rsi_requirements,
    rsi_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    rdi_reg,
    rdi_expr,
    rdi_control,
    rdi_branches,
    rdi_constraints,
    rdi_requirements,
    rdi_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    rbp_reg,
    rbp_expr,
    rbp_control,
    rbp_branches,
    rbp_constraints,
    rbp_requirements,
    rbp_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    rsp_reg,
    rsp_expr,
    rsp_control,
    rsp_branches,
    rsp_constraints,
    rsp_requirements,
    rsp_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    r8_reg,
    r8_expr,
    r8_control,
    r8_branches,
    r8_constraints,
    r8_requirements,
    r8_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    r9_reg,
    r9_expr,
    r9_control,
    r9_branches,
    r9_constraints,
    r9_requirements,
    r9_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    r10_reg,
    r10_expr,
    r10_control,
    r10_branches,
    r10_constraints,
    r10_requirements,
    r10_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    r11_reg,
    r11_expr,
    r11_control,
    r11_branches,
    r11_constraints,
    r11_requirements,
    r11_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    r12_reg,
    r12_expr,
    r12_control,
    r12_branches,
    r12_constraints,
    r12_requirements,
    r12_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    r13_reg,
    r13_expr,
    r13_control,
    r13_branches,
    r13_constraints,
    r13_requirements,
    r13_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    r14_reg,
    r14_expr,
    r14_control,
    r14_branches,
    r14_constraints,
    r14_requirements,
    r14_range
FROM
    tfps
order by n_instr, expr, constraints, branches;

SELECT
    pc,
    r15_reg,
    r15_expr,
    r15_control,
    r15_branches,
    r15_constraints,
    r15_requirements,
    r15_range
FROM
    tfps
order by n_instr, expr, constraints, branches;
