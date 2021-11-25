type tokens     is big_map (address, nat)
type allowances is big_map (address * address, nat) (* (sender,account) -> value *)

type storage is record [
  tokens      : tokens;
  allowances  : allowances;
  total_amount : nat;
]

type transfer is record [
	address_from : address;
	address_to   : address;
	value        : nat;
]

type approve is record [
	spender : address;
	value   : nat;
]

type getAllowance is record [
	owner    : address;
	spender  : address;
	callback : contract (nat);
]

type getBalance is record [
	owner    : address;
	callback : contract (nat);
]

type getTotalSupply is record [
	callback : contract (nat);
]

type action is
    Transfer       of transfer
|	Approve        of approve
|	GetAllowance   of getAllowance
|	GetBalance     of getBalance
|	GetTotalSupply of getTotalSupply



