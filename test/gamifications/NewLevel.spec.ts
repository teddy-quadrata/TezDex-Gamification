import { InMemorySigner } from "@taquito/signer";
import { MichelsonMap, TezosToolkit } from "@taquito/taquito"
import BigNumber from "bignumber.js";
import fs from "fs";
import { DexStorage } from "../helpers/types";
import TTDex from "../storage/TTDex";

const scorerJsonCode = require('../../contracts/main/gamifications/Scorer.tz.json')
const dexJsonCode = require('../../contracts/main/DexFA12.tz.json')
const dexJsonStorage = require("../../storage/dex.storage.json")
const accounts = require('../../scripts/sandbox/accounts')

function getLevelStorage() {
    const ranks = new MichelsonMap();

    const levelStorage = {
        trading_pair: accounts.alice.pkh, // contract of quipu contract
        score_token: accounts.alice.pkh,  // contract of score token
        score: 1,
        streak: 0,
        current_rank: 0,
        possible_ranks: ranks,
        multiplier: 1,
        owner: accounts.alice.pkh,
    }

    return levelStorage
}

function getDexStorage() {

    const storage = {
        tez_pool            : 1300, // make sure tez_pool/token_pool state vars are updated to reflect simulation values
        token_pool          : 1000,
        token_address       : "KT1VYsVfmobT7rsMVivvZ4J8i3bPiqz12NaH", // address of token to be traded
        baker_validator     : "KT1LcPGQzWWaqBdJKH32fn6RQXVeZPgutDqw",
        total_supply        : 0,
        ledger              :  MichelsonMap.fromLiteral({}),
        voters              :  MichelsonMap.fromLiteral({}),
        vetos               :  MichelsonMap.fromLiteral({}),
        votes               :  MichelsonMap.fromLiteral({}),
        veto                : 0,
        last_veto           : "2021-11-21T08:34:42Z",
        current_delegated   : "tz1PFeoTuFen8jAMRHajBySNyCwLmY5RqF9M",
        current_candidate   : "tz1PFeoTuFen8jAMRHajBySNyCwLmY5RqF9M",
        total_votes         : 0,
        reward              : 0,
        total_reward        : 0,
        reward_paid         : 0,
        reward_per_share    : 0,
        reward_per_sec      : 0,
        last_update_time    : "2021-11-21T08:34:42Z",
        period_finish       : "2021-11-21T08:34:42Z",
        user_rewards        :  MichelsonMap.fromLiteral({})
    }

    const fullDexStorage = {
        storage: storage,
        metadata: MichelsonMap.fromLiteral({}),
        dex_lambdas: MichelsonMap.fromLiteral({}),
        token_lambdas: MichelsonMap.fromLiteral({}),
    }

    return fullDexStorage
}


describe("BuildLevel()", function () {
    this.timeout(60000)

    let scorer, dex;
    let wwbtc, scoreFA12

    beforeEach(async () => {
        console.log("BuildLevel Test")
        const tezos = new TezosToolkit('http://localhost:8732');
        tezos.setProvider({ signer: await InMemorySigner.fromSecretKey(accounts.alice.sk) })

        // deploy wxtz

        await tezos.contract.originate({
            code: dexJsonCode.text_code,
            storage: getDexStorage(),
        }).then((originationOp) => {
            console.log(`Waiting for confirmation of origination for Dex: ${originationOp.contractAddress}...`);
            return originationOp.contract();
        }).then((contract) => {
            console.log(`Dex Origination completed.`);
            dex = contract
        }).catch((error) => console.log(`Dex Error: ${JSON.stringify(error, null, 2)}`));

        // give Dex KT 1300 tez
        // give Dex KT 1000 wxtz tokens

        await tezos.contract.originate({
            code: scorerJsonCode.text_code,
            storage: getLevelStorage()
        }).then((originationOp) => {
            console.log(`Waiting for confirmation of origination for Scorer: ${originationOp.contractAddress}...`);
            return originationOp.contract();
        }).then((contract) => {
            console.log(`Scorer Origination completed.`);
            scorer = contract
        }).catch((error) => console.log(`Scorer Error: ${JSON.stringify(error, null, 2)}`));

    });

    it("buys tokens and swaps from quipu", async () => {
        await scorer.methods.buy(4)
    })

    it.skip("sells tokens and swaps from quipu", async () => {
        await scorer.methods.sell(4)
    })
})