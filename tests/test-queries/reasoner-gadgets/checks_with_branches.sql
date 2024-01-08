SELECT
    pc,
    is_secret_inferable_w_branches,
    has_valid_base_w_branches,
    has_valid_secret_address_w_branches,
    is_cmove_independent_from_secret_w_branches,
    has_no_speculation_stop_w_branches,
    is_secret_below_cache_granularity_w_branches,
    can_perform_sliding_w_branches,
    is_secret_entropy_high_w_branches,
    can_perform_known_prefix_w_branches,
    is_max_secret_too_high_w_branches,
    can_adjust_base_w_branches
FROM
    gadgets
order by n_instr, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches;

SELECT
    pc,
    base_has_indirect_secret_dependency_w_branches,
    leak_secret_near_valid_base_w_branches,
    base_has_direct_secret_dependency_w_branches,
    can_ignore_direct_dependency_w_branches,
    is_branch_dependent_from_secret_w_branches,
    perform_training_w_branches,
    is_branch_dependent_from_uncontrolled_w_branches,
    perform_out_of_place_training_w_branches
FROM
    gadgets
order by n_instr, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches;
