SELECT
    pc,
    transmission_range_min,
    transmission_range_max,
    transmission_range_window,
    transmission_range_stride,
    transmission_range_and_mask,
    transmission_range_or_mask,
    transmission_range_exact,
    transmission_range_w_branches_min,
    transmission_range_w_branches_max,
    transmission_range_w_branches_window,
    transmission_range_w_branches_stride,
    transmission_range_w_branches_and_mask,
    transmission_range_w_branches_or_mask,
    transmission_range_w_branches_exact
FROM
    gadgets
order by n_instr, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches