-- Total number of exploitable gadgets, reported in Section 1 - Introduction.
SELECT "Exploitable Gadgets", COUNT(DISTINCT pc)
from all_gadgets
where exploitable='True'
and base_has_indirect_secret_dependency = 'False'

UNION ALL

-- Total number of reachable targets, reported in Section 5.4 - Evaluation.
SELECT "Reachable Targets", COUNT() 
FROM symbols_ibt 
WHERE name IN reachable

UNION ALL

-- Total number of exploitable call gadgets, reported in Section 5.4 - Evaluation.
SELECT "Exploitable Call Gadgets", COUNT(DISTINCT pc)
from call_gadgets
where exploitable='True'
and base_has_indirect_secret_dependency = 'False'

UNION ALL

-- Total number of exploitable jump gadgets, reported in Section 5.4 - Evaluation.
SELECT "Exploitable Jump Gadgets", COUNT(DISTINCT pc)
from jump_gadgets
where exploitable='True'
and base_has_indirect_secret_dependency = 'False'
;