SELECT
    pc,
    branches,
    branch_requirements,
    constraints,
    constraint_requirements,
    all_requirements,
    all_requirements_w_branches
FROM
    gadgets
order by pc, base_expr, transmitted_secret_expr, secret_address_expr, constraints, branches
