import { InMemorySigner } from "@taquito/signer";
import { MichelsonMap, TezosToolkit } from "@taquito/taquito"
import BigNumber from "bignumber.js";

const scorerJsonCode = require('../../contracts/main/gamifications/Scorer.tz.json')
const dexJsonCode = require('../../contracts/main/DexFA12.tz.json')
const dummyFA12JsonCode = require('../../contracts/main/gamifications/DummyFA12.tz.json')
const scoreFA12JsonCode = require('../../contracts/main/gamifications/ScoreFA12.tz.json')
const accounts = require('../../scripts/sandbox/accounts')

const token_to_tez = require('../../contracts/partials/gamifications/lambda1.tz.json')
const tez_to_tokens = require('../../contracts/partials/gamifications/lambda2.tz.json')

function getLevelStorage(dexAddr, scoreFA12Addr) {
    const ranks = new MichelsonMap();

    const levelStorage = {
        trading_pair: dexAddr, // contract of quipu contract
        score_token: scoreFA12Addr,  // contract of score token
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


    const dex_lambdas = new MichelsonMap()
    dex_lambdas.set(1, tez_to_tokens)
    dex_lambdas.set(2, token_to_tez)


    const fullDexStorage = {
        storage: storage,
        metadata: MichelsonMap.fromLiteral({}),
        dex_lambdas: dex_lambdas,
        token_lambdas: MichelsonMap.fromLiteral({}),
    }

    return fullDexStorage
}

function getExtendedFA12(admin) {

    const tokens = new MichelsonMap()

    const allowances = new MichelsonMap()

    const token_metadata = new MichelsonMap()

    const token0 = new MichelsonMap()

    token_metadata.set(0, token0)

    const storage = {
        tokens: tokens,
        allowances: allowances,
        total_amount: 0,
    }

    const extendedStorage = {
        standards: storage,
        admin: admin,
        token_metadata: token_metadata
    }


    return extendedStorage;
}




describe("BuildLevel()", function () {
    this.timeout(60000)

    let scorer, dex
    let wxtz, scoreFA12

    let scorerStorage, dexStorage
    let wxtzStorage, scoreFA12Storage

    before(async () => {
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
        wxtzStorage = await wxtz.storage()

        // deploy ScoreFA12
        await tezos.contract.originate({
            code: scoreFA12JsonCode.text_code,
            storage: getExtendedFA12(accounts.alice.pkh),
        }).then((originationOp) => {
            console.log(`Waiting for confirmation of origination for ScoreFA12: ${originationOp.contractAddress}...`);
            return originationOp.contract();
        }).then((contract) => {
            console.log(`ScoreFA12 Origination completed.`);
            scoreFA12 = contract
        }).catch((error) => console.log(`ScoreFA12 Error: ${JSON.stringify(error, null, 2)}`));
        scoreFA12Storage = await scoreFA12.storage()

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
        dexStorage = await dex.storage()


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
        const op = await wxtz.methods.mint(dex.address, 1000).send()
        await op.confirmation()

        // deploy scorer
        await tezos.contract.originate({
            code: scorerJsonCode.text_code,
            storage: getLevelStorage(dex.address, scoreFA12.address)
        }).then((originationOp) => {
            console.log(`Waiting for confirmation of origination for Scorer: ${originationOp.contractAddress}...`);
            return originationOp.contract();
        }).then((contract) => {
            console.log(`Scorer Origination completed.`);
            scorer = contract
        }).catch((error) => console.log(`Scorer Error: ${JSON.stringify(error, null, 2)}`));
        scorerStorage = await scorer.storage()
    });

    it("buys tokens and swaps from quipu", async () => {
        console.log(wxtz.address)
        console.log(dexStorage.storage.token_address)
        console.log(wxtz.parameterSchema.ExtractSignatures())
        const approveDex = await wxtz.methods.approve(dex.address, new BigNumber("115792089237316195423570985008687907853269984665640564039457584007913129639935")).send()
        await approveDex.confirmation()

        const swap1 = await dex.methods.tezToTokenPayment(6, accounts.alice.pkh).send({amount: 100, mutez: true})
        await swap1.confirmation()

        const swap2 = await dex.methods.tokenToTezPayment(1, 1, accounts.alice.pkh).send()
        await swap2.confirmation()

        const op = await scorer.methods.buy(4).send()
        await op.confirmation()
    })

    it("sells tokens and swaps from quipu", async () => {
        const sell = await scorer.methods.sell(4).send()
        await sell.confirmation()
    })
})