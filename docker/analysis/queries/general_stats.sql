-- Total number of exploitable gadgets
SELECT "Exploitable Gadgets", COUNT(DISTINCT pc)
from gadgets
where exploitable='True'
and base_has_indirect_secret_dependency = 'False'

UNION ALL

-- Total number of exploitable SLAM gadgets
SELECT "Exploitable SLAM Gadgets", COUNT(DISTINCT pc)
from gadgets
where exploitable_w_slam='True'

UNION ALL

-- Total number of exploitable dispatch gadgets
SELECT "Exploitable Dispatch Gadgets", COUNT(DISTINCT pc)
from tfps
where exploitable='True'

UNION ALL

-- Total number of exploitable SDB gadgets
SELECT "Exploitable SDB Gadgets", COUNT(DISTINCT pc)
FROM(

select pc
from gadgets
where transmitter = "TransmitterType.SECRET_DEP_BRANCH"
and
-- Make sure we have attacker control
 (
	cmp_value_control = "ControlType.CONTROLLED"
		and
		(secret_address_requirements_indirect_regs != cmp_value_requirements_indirect_regs
		and secret_address_requirements_direct_regs != cmp_value_requirements_direct_regs)

	OR
	(
	base_control == "ControlType.CONTROLLED" and
		(base_control_type == "BaseControlType.BASE_INDEPENDENT_FROM_SECRET" or base_control_type == "BaseControlType.COMPLEX_TRANSMISSION")
))

)
