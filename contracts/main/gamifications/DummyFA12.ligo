#include "../../partials/gamifications/IFA12.ligo"
#include "../../partials/gamifications/FA12Methods.ligo"


function main (const a : action; const s : storage) : list (operation) * storage is
 	case a of
   	    Transfer       (p) -> transfer (p,s)
	|	Approve        (p) -> approve (p,s)
	|	GetAllowance   (p) -> getAllowance (p,s)
	|   GetBalance     (p) -> getBalance (p,s)
	|	GetTotalSupply (p) -> getTotalSupply (p,s)
	end;