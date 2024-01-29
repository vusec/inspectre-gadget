SELECT
    pc,
    is_secret_inferable,
    has_valid_base,
    has_valid_secret_address,
    is_cmove_independent_from_secret,
    has_no_speculation_stop,
    is_secret_below_cache_granularity,
    can_perform_sliding,
    is_secret_entropy_high,
    can_perform_known_prefix,
    is_max_secret_too_high,
    can_adjust_base
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches;

SELECT
    pc,
    base_has_indirect_secret_dependency,
    leak_secret_near_valid_base,
    base_has_direct_secret_dependency,
    can_ignore_direct_dependency,
    is_branch_dependent_from_secret,
    perform_training,
    is_branch_dependent_from_uncontrolled,
    perform_out_of_place_training
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches;

