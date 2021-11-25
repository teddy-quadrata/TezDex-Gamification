#include "./IFA12.ligo"

type mint is record [
	admin : address;
	target : address;
	value : nat;
]

type burn is record [
	admin : address;
	target : address;
	value : nat;
]

type extendedAction is
	Mint 	of mint
|	Burn 	of burn
|	Methods of action


