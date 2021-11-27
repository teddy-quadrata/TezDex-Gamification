#include "./FA12Methods.ligo"

function mint(const p : mint; var s : extendedStorage) : list (operation) * extendedStorage is
    block {
        assert_with_error (s.admins contains Tezos.sender, "only the admin may call mint");

        s.standards.tokens[p.target] := (case s.standards.tokens[p.target] of
            Some(x) -> x + p.value
        |   None    -> p.value
        end);

    } with((nil: list (operation)), s)

function burn(const p : mint; var s : extendedStorage) : list (operation) * extendedStorage is
    block {
        assert_with_error (s.admins contains Tezos.sender, "only the admin may call burn");
        s.standards.tokens[p.target] := (case s.standards.tokens[p.target] of
            Some(x) -> (case is_nat(x - p.value) of Some(x) -> x | None -> 0n end)
        |   None    -> 0n
        end);
    } with((nil: list (operation)), s)