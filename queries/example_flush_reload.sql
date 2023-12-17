-- Demo query to list interesting gadgets that are exploitable with FLUSH+RELOAD.

SELECT
    uuid,  				-- unique identifier, useful for inspectre show
    name,  				-- user-chosen name for the entrypoint
    address AS entry_address, 	-- analysis entrypoint address 
    pc AS gadget_address,      	-- address of the transmission gadget
    n_instr, 					-- number of instructions between entrypoint and transmission
    n_branches,					-- number of branches between entrypoint and transmission
    transmission_expr, 			-- symbolic expression of the transmission
    base_expr,         			-- symbolic expression of the transmission base (e.g. address of the reload buffer for FLUSH+RELOAD)
    base_range_window,          -- size of the range of possible values for the base
    CAST(base_range_stride AS INT) AS base_range_stride, 			-- stride of the base range
    secret_address_expr, 			-- symbolic expression of the secret address
    secret_address_range_window,  	-- size of the range of possible values for the secret address
    CAST(inferable_bits_n_inferable_bits AS INT) AS inferable_bits,  -- number of bits of the secret that are transmitted through this transmission
    all_requirements,       -- list of registers and memory locations that the attacker needs to control to exploit the gadget
    branches,             	-- list of the addresses and conditions of the branches found between the entrypoint and the transmission
    constraints,          	-- list of "hard" constraints, inserted e.g. by CMOVE or SEXT instructions
	required_solutions AS required_techniques    -- what exploitation techniques are required to leak data through the gadget
FROM
    call_gadgets
WHERE
    exploitable = "True"
AND
    base_has_indirect_secret_dependency = "False" -- filter out cases in which the base address is loaded from an address near to the secret
AND
    transmitter = "TransmitterType.LOAD" -- select only LOAD transmissions (exclude TLB side channels)
AND
    base_control = "ControlType.CONTROLLED" -- select only gadgets where the base is completely controlled by the attacker (exclude prime+probe gadgets)
ORDER BY
    CAST(n_instr AS INT) ASC -- show the shortest ones first
LIMIT 100; -- only the first 100 gadgets
