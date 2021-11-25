#include "./IFA12.ligo"


type mint is record [
	target : address;
	value : nat;
]

type burn is record [
	target : address;
	value : nat;
]

type extendedStorage is record [
	standards		: storage;
	admin			: address;
	token_metadata	: big_map(nat, map(bytes, bytes))
]

type extendedAction is
	Mint 	of mint
|	Burn 	of burn
|	Methods of action


