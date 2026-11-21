SELECT
    pc,
    name,
    n_instr,
    n_dependent_loads,
    contains_spec_stop,
    bbls,
    loaded_expr,
    base_expr,
    uncontrolled_base_expr,
    attacker_expr
FROM
    halfgadgets
order by
    pc,
    n_instr
