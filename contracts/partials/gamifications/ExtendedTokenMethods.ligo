#include "./FA12Methods.ligo"

function mint(const p : mint; var s : storage) : list (operation) * storage is
    block {
        assert_with_error (Tezos.sender = p.admin, "only the admin may call mint");

        s.tokens[p.target] := 4n;

    } with((nil: list (operation)), s)

function burn(const p : mint; var s : storage) : list (operation) * storage is
    block {
        assert_with_error (Tezos.sender = p.admin, "only the admin may call burn")
    } with((nil: list (operation)), s)