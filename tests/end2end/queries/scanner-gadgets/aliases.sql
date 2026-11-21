SELECT
    pc,
    aliases
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
