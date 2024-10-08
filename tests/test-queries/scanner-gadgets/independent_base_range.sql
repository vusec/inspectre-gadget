SELECT
    pc,
    independent_base_range_min,
    independent_base_range_max,
    independent_base_range_window,
    independent_base_range_stride,
    independent_base_range_and_mask,
    independent_base_range_or_mask,
    independent_base_range_exact,
    independent_base_range_w_branches_min,
    independent_base_range_w_branches_max,
    independent_base_range_w_branches_window,
    independent_base_range_w_branches_stride,
    independent_base_range_w_branches_and_mask,
    independent_base_range_w_branches_or_mask,
    independent_base_range_w_branches_exact
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
