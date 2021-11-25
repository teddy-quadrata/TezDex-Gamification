
#include "../../partials/gamifications/IExtendedToken.ligo"
#include "../../partials/gamifications/ExtendedTokenMethods.ligo"

function main (const a : extendedAction; const s : storage) : list (operation) * storage is
 	case a of
   	    Methods 		(p) -> fa12Dispatcher(p, s)
	|	Mint 			(p) -> mint (p,s)
	|	Burn 			(p) -> burn (p,s)
	end;