-- We only test the most relevant fields
SELECT
    pc,
    secret_address_controlled_expr,
    secret_address_controlled_range_window,
    secret_address_controlled_range_stride,
    base_controlled_expr,
    base_controlled_range_window,
    base_controlled_range_stride,
    independent_base_controlled_expr,
    independent_base_controlled_range_window,
    independent_base_controlled_range_stride,
    cmp_value_controlled_expr,
    cmp_value_controlled_range_window,
    cmp_value_controlled_range_stride
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
