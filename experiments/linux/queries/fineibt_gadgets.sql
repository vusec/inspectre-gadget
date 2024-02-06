-- Total number of reachable dispatchers with a maximum of 3 dependent loads
-- within 10 instructions, reported in Section 9 - FineIBT bypass.
SELECT "FineIBT reachable dispatchers", COUNT(DISTINCT pc)
FROM all_tfps
WHERE name in reachable
AND requirements NOT like "%{'regs': [], %"
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
;