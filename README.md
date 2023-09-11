# Band Oracle Contract
A smart contract for enabling the Band Protocol relay system to keep crypto and fiat
currency prices updated #onFlow

## How it works?
The contract keeps a record of symbols and it's related market data 
that can be updated only by authorized parties and that can be queried
via script by any user of the Flow blockchain.

### Storing the data
Market for each symbol is stored on a dictionary as a contract level field `access(contract) let symbolsRefData: {String: RefData}`. The `RefData` structs stores the following information: 
```cadence
    pub struct RefData {
        // USD-rate, multiplied by 1e9.
        pub var rate: UInt64
        // UNIX epoch when data is last resolved. 
        pub var timestamp: UInt64
        // BandChain request identifier for this data.
        pub var requestID: UInt64
    }
```
This struct allows users to know when was the latest rate received and the oracle to discard updates from any relayer that are not up to date. Keep in mind that all data is stored by its USD-rate, and calculated in any other currency based on that.

### Updating the data
The account where the contract is deployed will be granted with a `OracleAdmin` resource. This resource could be use to create `DataUpdater` resources and publishing a `{&RelayUpdate}` capability to them. An authorized account can claim said capability at the time of creating a `Relay` resource. This resource will grant the ability to call the `updateData` method that will call contract function `access(contract) fun updateRefData (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64)` that will finally update the `symbolsRefData` dictionary.

### Querying the data
By calling the public function `pub fun getReferenceData (baseSymbol: String, quoteSymbol: String): RefData?` any Smart Contract or script would be able to get the price of a `quoteSymbol` in the `baseSymbol` currency. If there are none registries for either the base or quote symbol, the function will return `nil`.