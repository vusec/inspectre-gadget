SELECT
    pc,
    aliases
FROM
    gadgets
order by n_instr, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
