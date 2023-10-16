# This document describes the minimum set of manual tests to check the contract behavior.

## A relay will be granted permissions, then a series of rate updates and rate requests will happen:

1. First update (btc = 30k usd, flow = 0,5 usd) 
1. First rate request (BTC/FLOW = 60k)
1. Second update (btc = 60k usd, flow = 5 usd)
1. Second rate request (BTC/FLOW = 12k)
1. Third update (btc = 100k usd, flow = 10 usd) but with an older timestamp so it should fail
1. Third rate request (BTC/FLOW = 12k)
1. Force again third update so it overwrites a newer timestamp
1. Fourth rate request (BTC/FLOW = 10k)


### Flow CLI commands to run

#### Setup a relayer
- flow transactions send ./transactions/OracleAdmin/link_and_publish_data_updater_capability.cdc 0xfd43f9148d4b725d --signer default
- flow transactions send ./transactions/Relayer/create_new_relay.cdc 0xf669cb8d41ce0c74 --signer emulator-relayer

#### Build sign and send rates update transaction 1
- flow transactions build ./transactions/Relayer/relay_rates.cdc --args-json "$(cat ./transactions/Relayer/tx_scaffold/new_rates_1.json)"  --proposer emulator-relayer --payer emulator-relayer --authorizer emulator-relayer --filter payload --save ./transactions/Relayer/tx_scaffold/new_rates_1.rlp
- flow transactions sign ./transactions/Relayer/tx_scaffold/new_rates_1.rlp --signer emulator-relayer --filter payload --save ./transactions/Relayer/tx_scaffold/new_rates_1_signed.rlp
- flow transactions send-signed ./transactions/Relayer/tx_scaffold/new_rates_1_signed.rlp

#### Run get rates script
- flow scripts execute ./scripts/get_rates.cdc "BTC" "FLOW"

#### Build sign and send rates update transaction 2
- flow transactions build ./transactions/Relayer/relay_rates.cdc --args-json "$(cat ./transactions/Relayer/tx_scaffold/new_rates_2.json)"  --proposer emulator-relayer --payer emulator-relayer --authorizer emulator-relayer --filter payload --save ./transactions/Relayer/tx_scaffold/new_rates_2.rlp
- flow transactions sign ./transactions/Relayer/tx_scaffold/new_rates_2.rlp --signer emulator-relayer --filter payload --save ./transactions/Relayer/tx_scaffold/new_rates_2_signed.rlp
- flow transactions send-signed ./transactions/Relayer/tx_scaffold/new_rates_2_signed.rlp

#### Run get rates script
- flow scripts execute ./scripts/get_rates.cdc "BTC" "FLOW"

#### Build sign and send rates update transaction 3
- flow transactions build ./transactions/Relayer/relay_rates.cdc --args-json "$(cat ./transactions/Relayer/tx_scaffold/new_rates_3.json)"  --proposer emulator-relayer --payer emulator-relayer --authorizer emulator-relayer --filter payload --save ./transactions/Relayer/tx_scaffold/new_rates_3.rlp
- flow transactions sign ./transactions/Relayer/tx_scaffold/new_rates_3.rlp --signer emulator-relayer --filter payload --save ./transactions/Relayer/tx_scaffold/new_rates_3_signed.rlp
- flow transactions send-signed ./transactions/Relayer/tx_scaffold/new_rates_3_signed.rlp

#### Run get rates script
- flow scripts execute ./scripts/get_rates.cdc "BTC" "FLOW"

#### Build sign and send force update transaction
- flow transactions build ./transactions/Relayer/force_relay_rates.cdc --args-json "$(cat ./transactions/Relayer/tx_scaffold/new_rates_3.json)"  --proposer emulator-relayer --payer emulator-relayer --authorizer emulator-relayer --filter payload --save ./transactions/Relayer/tx_scaffold/force_new_rates.rlp
- flow transactions sign ./transactions/Relayer/tx_scaffold/force_new_rates.rlp --signer emulator-relayer --filter payload --save ./transactions/Relayer/tx_scaffold/force_new_rates_signed.rlp
- flow transactions send-signed ./transactions/Relayer/tx_scaffold/force_new_rates_signed.rlp

#### Run get rates script
- flow scripts execute ./scripts/get_rates.cdc "BTC" "FLOW"