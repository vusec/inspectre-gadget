-- Demo query to list interesting gadgets that are exploitable with FLUSH+RELOAD.
SELECT
    uuid
FROM
    call_gadgets
WHERE
    exploitable = "True"
    AND base_has_indirect_secret_dependency = "False" -- filter out cases in which the base address is loaded from an address near to the secret
    AND transmitter = "TransmitterType.LOAD" -- select only LOAD transmissions (exclude TLB side channels)
    AND base_control = "ControlType.CONTROLLED" -- select only gadgets where the base is completely controlled by the attacker (exclude prime+probe gadgets)
ORDER BY
    CAST(n_instr AS INT) ASC -- show the shortest ones first
LIMIT
    100;

-- only the first 100 gadgets
