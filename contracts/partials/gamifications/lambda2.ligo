#include "../IDex.ligo"
#include "../Common.ligo"

(* Exchange Tez to tokens *)
function tez_to_token (const p : dex_action; var s : dex_storage; const this : address) : return is
  block {
    var operations : list(operation) := list[];
    case p of
      | InitializeExchange(n) -> skip
      | TezToTokenPayment(args) -> {
        (* ensure *)
        if Tezos.amount / 1mutez > 0n (* non-zero amount of tokens exchanged *)
        then skip
        else failwith ("Dex/zero-amount-in");

        if args.min_out > 0n (* non-zero amount of tokens exchanged *)
        then skip
        else failwith ("Dex/zero-min-amount-out");

        (* calculate amount out *)
        const tez_in_with_fee : nat = Tezos.amount / 1mutez * 997n;
        const numerator : nat = tez_in_with_fee * s.token_pool;
        const denominator : nat = s.tez_pool * 1000n + tez_in_with_fee;

        (* calculate swapped token amount *)
        const tokens_out : nat = numerator / denominator;

        (* ensure requirements *)
        if tokens_out >= args.min_out (* sutisfy minimal requested amount *)
        then skip else failwith("Dex/wrong-min-out");

        if tokens_out > s.token_pool / 3n (* not cause a high price impact *)
        then failwith("Dex/high-out")
        else skip;

        (* update reserves *)
        s.token_pool := abs(s.token_pool - tokens_out);
        s.tez_pool := s.tez_pool + Tezos.amount / 1mutez;

        (* prepare the transfer operation *)
        operations := Tezos.transaction(
          wrap_transfer_trx(this, args.receiver, tokens_out, s),
          0mutez,
          get_token_contract(s.token_address)
        ) # operations;
      }
      | TokenToTezPayment(n) -> skip
      | InvestLiquidity(n) -> skip
      | DivestLiquidity(n) -> skip
      | Vote(n) -> skip
      | Veto(voter) -> skip
      | WithdrawProfit(n) -> skip
    end
  } with (operations, s)
