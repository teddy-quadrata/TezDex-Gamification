import { InMemorySigner } from "@taquito/signer";
import { MichelsonMap, TezosToolkit } from "@taquito/taquito"

const scorerJsonCode = require('../../contracts/main/gamifications/Scorer.tz.json')
const accounts = require('../../scripts/sandbox/accounts')

describe("BuildLevel()", () => {
    beforeEach(async () => {
        console.log("BuildLevel Test")
        const tezos = new TezosToolkit('http://localhost:8732');
        tezos.setProvider({ signer: await InMemorySigner.fromSecretKey(accounts.alice.sk) })

        console.log(await tezos.tz.getBalance('tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb'))
        const dataMap = new MichelsonMap();
        dataMap.set('0', '0');
        const levelStorage = {
            trading_pair : accounts.alice.pkh, // contract of quipu contract
            score_token : accounts.alice.pkh,  // contract of score token
            score : 1,
            streak : 0,
            current_rank : 0,
            possible_ranks : dataMap,
            multiplier : 1,
            owner : accounts.alice.pkh,
        }

        await tezos.contract.originate({
            code: scorerJsonCode.text_code,
            storage: levelStorage

        }).then((originationOp) => {
            console.log(`Waiting for confirmation of origination for ${originationOp.contractAddress}...`);
            return originationOp.contract();
          }).then((contract) => {
            console.log(`Origination completed.`);
          }).catch((error) => console.log(`Error: ${JSON.stringify(error, null, 2)}`));
    });

    it("correctly sets up storage", async () => {

    });
}) 