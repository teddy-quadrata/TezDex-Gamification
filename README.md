# Description

This project is a fork of quipuswap and adds logic that makes defi into a game with on chain scoring metrics and player levels calculated on chain.


# Prerequisites

- Installed NodeJS (tested with NodeJS v12+)

- Installed Yarn (NPM isn't working properly with `ganache-cli@6.11.0-tezos.0`)

- Installed Ligo:

```
curl https://gitlab.com/ligolang/ligo/raw/dev/scripts/installer.sh | bash -s "next"
```

- Installed node modules:

```
cd quipuswap-core && yarn
```

- Configure `truffle-config.js` if [needed](https://www.trufflesuite.com/docs/tezos/truffle/reference/configuring-tezos-projects).

# Quick Start

To compile and deploy contracts to Delphinet

1. Chose configure the version - `FA12` or `FA2` - by setting `EXCHANGE_TOKEN_STANDARD` in `.env` and run:

```
yarn migrate
```

For other networks:

```
yarn migrate --network NAME
```

# Usage

Contracts are processed in the following stages:

1. Compilation
2. Deployment
3. Configuration
4. Interactions on-chain

As the Quipuswap supports 2 token standards that vary only in the token interface implementation and the inter contract communication between Dex and external tokens, the shared codebase is used. Therefore to work with the specific standard version, you should configure it by setting `EXCHANGE_TOKEN_STANDARD` in `.env` to either `FA12` or `FA2`.

## Compilation

To compile the contracts run:

```
yarn compile
```

Artifacts are stored in the `build/contracts` directory.

## Deployment

For deployment step the following command should be used:

```
yarn migrate
```

Addresses of deployed contracts are displayed in terminal. At this stage, new MetadataStorage, Factory are originated. Aditionaly, for testnets two new pairs are deployed.

# Testing

If you'd like to run tests on the local environment, you might want to run `ganache-cli` for Tezos using the following command:

```
yarn start-sandbox
```

Truffle framework is used for testing. Run:

```
yarn test
```

NOTE: if you want to use a different network, configure `truffle-config.js`. If you need to use a different standard, configure `$EXCHANGE_TOKEN_STANDARD` in `.env`
