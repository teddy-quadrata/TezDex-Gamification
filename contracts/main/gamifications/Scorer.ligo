#include "../../partials/gamifications/IScorer.ligo"
#include "../../partials/IDex.ligo"
#include "../../partials/Common.ligo"


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
    const operations : list(operation) = list[op];


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
      receiver = level.owner;
    ];


    // add to operations list
    const op : operation = Tezos.transaction(params, 0tez, trading);
    const operations : list(operation) = list[op;  Tezos.transaction(unit, 0tez, (Tezos.self("%postSell") : contract(unit)));];

  } with (operations, level)


function preSell (const approve : nat; const level : level_storage) : return_level is
  block {


    const operations : list(operation) =

    list [
      Tezos.transaction((level.trading_pair, approve), 0tez, get_approval_contract(level.score_token));
      Tezos.transaction(wrap_transfer_trx(Tezos.sender, Tezos.self_address, approve), 0tez, get_token_contract(level.score_token));
    ];
  } with(operations, level)


function postSell (var level : level_storage) : return_level is
  block {
    level.score := level.score + 1n;
  } with((nil : list(operation)), level)


function main (const action : game_action; const level : level_storage): return_level is
  case action of
    Buy (x) -> buy (x, level)
  | PreSell (x) -> preSell(x, level)
  | Sell (x) -> sell (x, level)
  | PostSell (x) -> postSell(level)
  end