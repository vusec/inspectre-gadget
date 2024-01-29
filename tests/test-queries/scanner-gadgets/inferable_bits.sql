SELECT
    pc,
    inferable_bits_spread_high,
    inferable_bits_spread_low,
    inferable_bits_spread_total,
    inferable_bits_n_inferable_bits
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
