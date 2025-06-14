function fifth_order()
    clear_caches!()
    H = Terms([Term(; rotating=0), Term(; rotating=1)])
    set_hamiltonian!(H)

    return K(5)
end
fifth_order()

function fifth_order_van_Vleck!(SUITE)
    SUITE["van Vleck expansion"]["Fifth order"] = @benchmarkable fifth_order() seconds=50

    return nothing
end
