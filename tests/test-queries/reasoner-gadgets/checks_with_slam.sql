SELECT
    pc,
    slam_has_exact_secret_range,
    slam_has_aligned_secret_bytes,
    slam_is_an_user_address_translation,
    slam_can_ignore_direct_dependency
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches;
