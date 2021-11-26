type tokens     is big_map (address, nat)
type allowances is big_map (address * address, nat)

type storage is record [
  tokens      : tokens;
  allowances  : allowances;
  total_amount : nat;
]

type transfer is michelson_pair(address, "from", michelson_pair(address, "to", nat, "value"), "")

type approve is michelson_pair(address, "spender", nat, "value")

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



