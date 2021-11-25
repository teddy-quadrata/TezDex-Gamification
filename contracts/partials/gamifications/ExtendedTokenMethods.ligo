#include "./FA12Methods.ligo"

function mint(const p : mint; var s : storage) : list (operation) * storage is
    block {
        assert_with_error (Tezos.sender = p.admin, "only the admin may call mint");

        s.tokens[p.target] := (case s.tokens[p.target] of
            Some(x) -> x + p.value
        |   None    -> p.value
        end);

    } with((nil: list (operation)), s)

function burn(const p : mint; var s : storage) : list (operation) * storage is
    block {
        assert_with_error (Tezos.sender = p.admin, "only the admin may call burn");
        s.tokens[p.target] := (case s.tokens[p.target] of
            Some(x) -> (case is_nat(x - p.value) of Some(x) -> x | None -> 0n end)
        |   None    -> 0n
        end);
    } with((nil: list (operation)), s)