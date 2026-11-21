SELECT
    pc,
    constraints,
    all_requirements,
    constraint_requirements,
    branches
FROM
    halfgadgets
order by
    pc,
    expr,
    constraints,
    branches
