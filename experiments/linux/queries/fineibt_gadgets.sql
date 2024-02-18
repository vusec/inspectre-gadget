-- Total number of reachable dispatchers with a maximum of 3 dependent loads
-- within 10 instructions, reported in Section 9 - FineIBT bypass.
SELECT "FineIBT reachable dispatchers", COUNT(DISTINCT pc)
FROM all_tfps
WHERE name in reachable
AND requirements NOT like "%{'regs': [], %"
AND contains_spec_stop = 'False'
AND CAST(n_dependent_loads AS INT) <=3
AND CAST(n_instr AS INT) <= 10

UNION ALL

-- Total number of reachable gadgets with a maximum of 4 dependent loads
-- within 15 instructions, reported in Section 9 - FineIBT bypass.
SELECT "FineIBT reachable gadgets", COUNT(DISTINCT pc)
FROM all_gadgets
WHERE name in reachable
AND exploitable = 'True'
AND base_has_indirect_secret_dependency = 'False'
AND CAST(n_dependent_loads AS INT) <=4
AND CAST(n_instr AS INT) <= 15

UNION ALL

-- Total number of non-reachable gadgets with a maximum of 4 dependent loads
-- within 15 instructions, reported in Section 9 - FineIBT bypass.
SELECT "FineIBT unreachable gadgets", COUNT(DISTINCT pc)
FROM all_gadgets
WHERE name not in reachable
AND exploitable = 'True'
AND base_has_indirect_secret_dependency = 'False'
AND CAST(n_dependent_loads AS INT) <=4
AND CAST(n_instr AS INT) <= 15

UNION ALL

-- Total number of non-reachable gadgets with a maximum of 4 dependent loads
-- within 15 instructions, reported in Section 9 - FineIBT bypass.
SELECT "FineIBT half-gadget dispatchers", COUNT(DISTINCT pc)
FROM all_tfps
WHERE
requirements NOT like "%{'regs': [], %"
AND contains_spec_stop = 'False'
AND CAST(n_instr AS INT) < 30
AND 
(
(rsi_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND rsi_expr LIKE "%LOAD%")
OR (rdi_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND rdi_expr LIKE "%LOAD%")
OR (rax_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND rax_expr LIKE "%LOAD%")
OR (rbx_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND rbx_expr LIKE "%LOAD%")
OR (rcx_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND rcx_expr LIKE "%LOAD%")
OR (rdx_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND rdx_expr LIKE "%LOAD%")
OR (r8_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND r8_expr LIKE "%LOAD%")
OR (r9_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND r9_expr LIKE "%LOAD%")
OR (r10_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND r10_expr LIKE "%LOAD%")
OR (r11_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND r11_expr LIKE "%LOAD%")
OR (r12_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND r12_expr LIKE "%LOAD%")
OR (r13_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND r13_expr LIKE "%LOAD%")
OR (r14_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND r14_expr LIKE "%LOAD%")
OR (r15_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND r15_expr LIKE "%LOAD%")
OR (rbp_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND rbp_expr LIKE "%LOAD%")
OR (rsp_control = 'TFPRegisterControlType.POTENTIAL_SECRET' AND rsp_expr LIKE "%LOAD%")
)
;