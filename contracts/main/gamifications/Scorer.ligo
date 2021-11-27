#include "../../partials/IDex.ligo"
#include "../../partials/Common.ligo"
#include "../../partials/gamifications/IScorer.ligo"

function awardScore(const scoreTokenAddr : address; const player : address; const score : nat) : operation is block {

  const scoreToken : contract(record[target: address; value : nat]) = case (Tezos.get_entrypoint_opt("%mint", scoreTokenAddr) : option(contract(record[target: address; value : nat]))) of
  Some(x) -> x
  | None -> (failwith("Mint Score Entrypoint not Found") : contract(record[target: address; value : nat]))
  end;

  const mintTx : operation = Tezos.transaction(record [target=player; value=score], 0tez, scoreToken);
} with mintTx


function buy (const purchase_quantity : buy_params; var level : level_storage) : return_level is

  block {

    // fetch contract for buying
    const trading : contract(tez_to_token_payment_params) =
    case (Tezos.get_entrypoint_opt("%tezToTokenPayment", level.trading_pair) : option (contract(tez_to_token_payment_params))) of
    Some (contract) -> contract
    |None -> (failwith("Level not found") : contract(tez_to_token_payment_params))
    end;

    // calculate score and update level_storage accordingly
    level.score := level.score + purchase_quantity;
    level.principal := level.principal + purchase_quantity;

    // mint score on this address

    // create transaction operation args
    const params : tez_to_token_payment_params = record [
      min_out = 1n;
      receiver = level.owner;
    ];

    // add to operations list
    const op : operation = Tezos.transaction(params, purchase_quantity * 1mutez, trading);
    const operations : list(operation) = list[op; awardScore(level.score_token, level.owner, purchase_quantity)];


  } with (operations, level)

function sell (const sell_quantity : sell_params; const level : level_storage) : return_level is

  block {

    // calculate score and update level_storage accordingly
    // mint score on this address

    // fetch contract for selling
    const trading : contract(token_to_tez_payment_params) =
    case (Tezos.get_entrypoint_opt("%tokenToTezPayment", level.trading_pair) : option (contract(token_to_tez_payment_params))) of
    Some (contract) -> contract
    |None -> (failwith("Level not found") : contract(token_to_tez_payment_params))
    end;


    // create transaction operation args
    const params : token_to_tez_payment_params = record [
      amount = sell_quantity;
      min_out = 1n;
      receiver = Tezos.self_address;
    ];


    // add to operations list
    const op : operation = Tezos.transaction(params, 0tez, trading);
    const operations : list(operation) = list[
      op;
      //Tezos.transaction(unit, 0tez, (Tezos.self("%postSell") : contract(unit)));
    ];

  } with (operations, level)


function preSell (const approve : nat; const level : level_storage) : return_level is
  block {


    const operations : list(operation) =

    list [
      Tezos.transaction((level.trading_pair, approve), 0tez, get_approval_contract(level.level_token));
      Tezos.transaction(wrap_transfer_trx(Tezos.sender, Tezos.self_address, approve), 0tez, get_token_contract(level.level_token));
    ];
  } with(operations, level)


(*This default function gets called automatically when funds are transfered out of quipuswap*)
function postSell (var level : level_storage) : return_level is
  block {
    assert_with_error(Tezos.sender = level.trading_pair, "Sender isn't the dex");
    const tez_out : nat = Tezos.amount / 1tez;

    const profit_score : nat = case (is_nat(level.principal - tez_out) : option(nat)) of
     Some(x) -> x
    |None    -> 1n
    end;

    level.score := level.score + profit_score;

    // mint profit_score fa12 tokens

    const ops : list(operation) = list[awardScore(level.score_token, level.owner, profit_score)];

  } with(ops, level)


function main (const action : game_action; const level : level_storage): return_level is
  case action  of
      Buy (x) -> buy (x, level)
    | PreSell (x) -> preSell(x, level)
    | Sell (x) -> sell (x, level)
    | PostSell -> postSell(level)
    | Default -> postSell(level)
  end;