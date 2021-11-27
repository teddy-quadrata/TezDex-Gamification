
#include "../../partials/gamifications/IExtendedToken.ligo"
#include "../../partials/gamifications/ExtendedTokenMethods.ligo"

function main (const a : extendedAction; const s : extendedStorage) : list (operation) * extendedStorage is
 	case a of
   	    Methods 		(p) -> (case fa12Dispatcher(p, s.standards) of (x, y) -> (x, record [standards = y; admins=s.admins; token_metadata=s.token_metadata]) end)
	|	Mint 			(p) -> mint (p,s)
	|	Burn 			(p) -> burn (p,s)
	|	AddAdmin		(p) -> addAdmin(p, s)
	end;