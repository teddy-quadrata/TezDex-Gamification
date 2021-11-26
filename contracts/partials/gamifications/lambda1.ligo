#include "../IDex.ligo"
#include "../Common.ligo"


(* Exchange tokens to tez, note: tokens should be approved before the operation *)
function token_to_tez (const p : dex_action; var s : dex_storage; const this : address) : return is
  block {
    var operations : list(operation) := list[];
    case p of
      | InitializeExchange(n) -> skip
      | TezToTokenPayment(n) -> skip
      | TokenToTezPayment(args) -> {
        (* ensure *)
        if args.amount > 0n (* non-zero amount of tokens exchanged *)
        then skip
        else failwith ("Dex/zero-amount-in");

        if args.min_out > 0n (* non-zero amount of tokens exchanged *)
        then skip
        else failwith ("Dex/zero-min-amount-out");

        (* calculate amount out *)
        const token_in_with_fee : nat = args.amount * 997n;
        const numerator : nat = token_in_with_fee * s.tez_pool;
        const denominator : nat = s.token_pool * 1000n + token_in_with_fee;
        const tez_out : nat = numerator / denominator;

        (* ensure requirements *)
        if tez_out >= args.min_out (* sutisfy minimal requested amount *)
        then skip
        else failwith("Dex/wrong-min-out");
        if tez_out <= s.tez_pool / 3n (* not cause a high price impact *)
        then skip
        else failwith("Dex/high-out");

        (* update reserves *)
        s.token_pool := s.token_pool + args.amount;
        s.tez_pool := abs(s.tez_pool - tez_out);

        (* prepare operations to withdraw user's tokens and transfer XTZ *)
        operations := list [Tezos.transaction(
            wrap_transfer_trx(Tezos.sender, this, args.amount, s),
            0mutez,
            get_token_contract(s.token_address));
          Tezos.transaction(
            unit,
            tez_out * 1mutez,
            (get_contract(args.receiver) : contract(unit)));
        ];
      }
      | InvestLiquidity(n) -> skip
      | DivestLiquidity(n) -> skip
      | Vote(n) -> skip
      | Veto(voter) -> skip
      | WithdrawProfit(n) -> skip
    end
  } with (operations, s)

