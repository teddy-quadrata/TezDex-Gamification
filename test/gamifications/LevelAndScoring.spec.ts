import { InMemorySigner } from "@taquito/signer";
import { MichelsonMap, TezosToolkit } from "@taquito/taquito"

const scorerJsonCode = require('../../contracts/main/gamifications/Scorer.tz.json')
const dexJsonCode = require('../../contracts/main/DexFA12.tz.json')
const dummyFA12JsonCode = require('../../contracts/main/gamifications/DummyFA12.tz.json')
const scoreFA12JsonCode = require('../../contracts/main/gamifications/ScoreFA12.tz.json')
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

function getDexStorage(tokenAddr) {

    const storage = {
        tez_pool: 1300, // make sure tez_pool/token_pool state vars are updated to reflect simulation values
        token_pool: 1000,
        token_address: tokenAddr, // address of token to be traded
        baker_validator: "KT1LcPGQzWWaqBdJKH32fn6RQXVeZPgutDqw",
        total_supply: 1300,
        ledger: MichelsonMap.fromLiteral({}),
        voters: MichelsonMap.fromLiteral({}),
        vetos: MichelsonMap.fromLiteral({}),
        votes: MichelsonMap.fromLiteral({}),
        veto: 0,
        last_veto: "2021-11-21T08:34:42Z",
        current_delegated: "tz1PFeoTuFen8jAMRHajBySNyCwLmY5RqF9M",
        current_candidate: "tz1VceyYUpq1gk5dtp6jXQRtCtY8hm5DKt72",
        total_votes: 0,
        reward: 0,
        total_reward: 0,
        reward_paid: 0,
        reward_per_share: 0,
        reward_per_sec: 0,
        last_update_time: "2021-11-21T08:34:42Z",
        period_finish: "2021-11-21T08:34:42Z",
        user_rewards: MichelsonMap.fromLiteral({})
    }

    const fullDexStorage = {
        storage: storage,
        metadata: MichelsonMap.fromLiteral({}),
        dex_lambdas: MichelsonMap.fromLiteral({}),
        token_lambdas: MichelsonMap.fromLiteral({}),
    }

    return fullDexStorage
}

function getExtendedFA12(admin) {

    const tokens = new MichelsonMap()

    const allowances = new MichelsonMap()

    const storage = {
        tokens: tokens,
        allowances: allowances,
        total_amount: 0,
    }

    const extendedStorage = {
        standards: storage,
        admin: admin
    }

    return extendedStorage;
}




describe("BuildLevel()", function () {
    this.timeout(60000)

    let scorer, dex;
    let wxtz, scoreFA12

    beforeEach(async () => {
        console.log("BuildLevel Test")
        const tezos = new TezosToolkit('http://localhost:8732');
        tezos.setProvider({ signer: await InMemorySigner.fromSecretKey(accounts.alice.sk) })


        // deploy wxtz
        await tezos.contract.originate({
            code: dummyFA12JsonCode.text_code,
            storage: getExtendedFA12(accounts.alice.pkh),
        }).then((originationOp) => {
            console.log(`Waiting for confirmation of origination for WXTZ: ${originationOp.contractAddress}...`);
            return originationOp.contract();
        }).then((contract) => {
            console.log(`WXTZ Origination completed.`);
            wxtz = contract
        }).catch((error) => console.log(`WXTZ Error: ${JSON.stringify(error, null, 2)}`));


        // deploy dex
        await tezos.contract.originate({
            code: dexJsonCode.text_code,
            storage: getDexStorage(wxtz.address),
        }).then((originationOp) => {
            console.log(`Waiting for confirmation of origination for Dex: ${originationOp.contractAddress}...`);
            return originationOp.contract();
        }).then((contract) => {
            console.log(`Dex Origination completed.`);
            dex = contract
        }).catch((error) => console.log(`Dex Error: ${JSON.stringify(error, null, 2)}`));


        // give Dex KT 1300 mutez
        const amount = 1.3;
        console.log(`Transfering ${amount} tez to ${dex.address}...`);
        await tezos.contract.transfer({
            to: accounts.bob.pkh, amount: amount
        }).then(async (op) => {
            console.log(`Waiting for ${op.hash} to be confirmed...`);
            return op.confirmation(1).then(() => op.hash);
        }).then((hash) => {
            console.log(`Operation injected: ${hash}`)
        }).catch((error) => console.log(`Error: ${error} ${JSON.stringify(error, null, 2)}`));

        // give Dex KT 1000 wxtz tokens
        const storage = await wxtz.storage()
        console.log("admin")
        console.log(await storage['standards']['tokens'].get(dex.address))
        const op = await wxtz.methods.mint(dex.address, 1000).send()
        await op.confirmation()
        console.log(await storage['standards']['tokens'].get(dex.address))

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