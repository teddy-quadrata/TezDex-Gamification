
function transfer (const p : transfer; const s: storage) : list (operation) * storage is block {
   var new_allowances : allowances := Big_map.empty;
	if Tezos.sender = p.0
	then { new_allowances := s.allowances; }
	else {
		var authorized_value : nat :=
		case (Big_map.find_opt ((Tezos.sender,p.0), s.allowances)) of
				Some (value) -> value
			|	None       -> 0n
		end;
		if (authorized_value < p.1.1)
		then { failwith("Not Enough Allowance")}
		else { new_allowances := Big_map.update ((Tezos.sender,p.0), (Some (abs(authorized_value - p.1.1))), s.allowances) }
	};
	var sender_balance : nat := case (Big_map.find_opt (p.0, s.tokens)) of
		Some (value) -> value
	|	None        -> 0n
	end;
	var new_tokens : tokens := Big_map.empty;
	if (sender_balance < p.1.1)
	then { failwith ("Not Enough Balance")}
	else {
		new_tokens := Big_map.update (p.0, (Some (abs(sender_balance - p.1.1))), s.tokens);
		var receiver_balance : nat := case (Big_map.find_opt (p.1.0, s.tokens)) of
			Some (value) -> value
		|	None        -> 0n
		end;
		new_tokens := Big_map.update (p.1.0, (Some (receiver_balance + p.1.1)), new_tokens);
	}
} with ((nil: list (operation)), s with record [tokens = new_tokens; allowances = new_allowances])

function approve (const p : approve; const s : storage) : list (operation) * storage is block {
	var previous_value : nat := case Big_map.find_opt ((p.spender, Tezos.sender), s.allowances) of
		Some (value) -> value
	|	None -> 0n
	end;
	var new_allowances : allowances := Big_map.empty;
	if previous_value > 0n and p.value > 0n
	then { failwith ("Unsafe Allowance Change")}
	else {
		new_allowances := Big_map.update ((p.spender, Tezos.sender), (Some (p.value)), s.allowances);
	}
} with ((nil: list (operation)), s with record [allowances = new_allowances])

function getAllowance (const p : getAllowance; const s : storage) : list (operation) * storage is block {
	var value : nat := case Big_map.find_opt ((p.owner, p.spender), s.allowances) of
		Some (value) -> value
	|	None -> 0n
	end;
	var op : operation := Tezos.transaction (value, 0mutez, p.callback);
} with (list [op],s)

function getBalance (const p : getBalance; const s : storage) : list (operation) * storage is block {
	var value : nat := case Big_map.find_opt (p.owner, s.tokens) of
		Some (value) -> value
	|	None -> 0n
	end;
	var op : operation := Tezos.transaction (value, 0mutez, p.callback);
} with (list [op],s)

function getTotalSupply (const p : getTotalSupply; const s : storage) : list (operation) * storage is block {
  var total : nat := s.total_amount;
  var op : operation := Tezos.transaction (total, 0mutez, p.callback);
} with (list [op],s)

function fa12Dispatcher (const a : action; const s : storage) : list (operation) * storage is
	case a of
    	Transfer		(p) -> transfer (p,s)
	|	Approve        	(p) -> approve (p,s)
	|	GetAllowance   	(p) -> getAllowance (p,s)
	|   GetBalance     	(p) -> getBalance (p,s)
	|	GetTotalSupply 	(p) -> getTotalSupply (p,s)
	end;
