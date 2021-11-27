(* achivements *)
type ranks is map (nat, string)

type buy_params is nat
type sell_params is nat

(* gamification features *)
type game_action is
 Buy of buy_params
| PreSell of nat
| Sell of sell_params
| PostSell of unit

(* main storage, also acts as score treasury *)
type level_storage is record [
    trading_pair : address; // contract of quipu contract
    score_token : address;  // contract of score token
    score : nat;
    streak : nat;
    current_rank : nat;
    possible_ranks : ranks;
    multiplier : nat;
    owner : address;
    principal: nat;
]

type return_level is list (operation) * level_storage


