# Band Oracle Contract
The Cadence smart contract enabling integration of the Band Protocol Oracle network. The oracle network presently offers 5 cryptocurrency [price quotes](https://data.bandprotocol.com/) available to any Cadence applications, contracts or transactions. Currencies supported are: ETH, FLOW, USDC, USDT, WBTC.

To learn more about Band Protocol please refer to: https://faq.bandprotocol.com/

## Contract Addresses 

|Name|Testnet|Mainnet|
|----|-------|-------|
|[BandOracle](contracts/BandOracle.cdc)|[0x2c71de7af78d1adf](https://contractbrowser.com/A.2c71de7af78d1adf.BandOracle)|[]()|
|[BandOracle](contracts/BandOracle.cdc)|[]()|[0x6801a6222ebf784a](https://contractbrowser.com/A.6801a6222ebf784a.BandOracle)|

## How it works?
The contract keeps a record of symbols and the corresponding financial price data for them. While financial data are only updated by authorized BandChain relayers, they can be queried via a script by any user or application on the Flow blockchain.

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
This struct provides the caller with the data received from the oracle network for the symbol in question. Keep in mind that all data is normalized and stored using a USD conversion rate, meaning that conversions into other symbols will derive from that.

### Updating the data
The account where the contract is deployed will be granted an `OracleAdmin` resource. This resource can create `DataUpdater` resources and publish a `{&RelayUpdate}` capability to them. An authorized account - belonging to a relayer - can claim said capability at the time of creating a `Relay` resource. This resource will grant the ability to call the `updateData` method that will call contract function `access(contract) fun updateRefData (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64)` which in turn updates the `symbolsRefData` dictionary.

### Querying the data
When invoking the public function `pub fun getReferenceData (baseSymbol: String, quoteSymbol: String): RefData?` calling contracts or scripts would be provided the price corresponding to `quoteSymbol` in the `baseSymbol` currency. If there are no entries registered for either the base or quote symbols the function will return `nil`.

### Fees

[TBD]
