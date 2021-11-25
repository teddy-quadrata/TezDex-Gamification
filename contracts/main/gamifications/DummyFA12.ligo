
#include "../../partials/gamifications/IExtendedToken.ligo"
#include "../../partials/gamifications/ExtendedTokenMethods.ligo"

function main (const a : extendedAction; const s : extendedStorage) : list (operation) * extendedStorage is
 	case a of
   	    Methods 		(p) -> (case fa12Dispatcher(p, s.standards) of (x, y) -> (x, record [standards = y; admin=s.admin; token_metadata=s.token_metadata]) end)
	|	Mint 			(p) -> mint (p,s)
	|	Burn 			(p) -> burn (p,s)
	end;