# Contract `BandOracle`

```cadence
pub contract BandOracle {

    pub let OracleAdminStoragePath: StoragePath

    pub let OracleAdminPrivatePath: PrivatePath

    pub let RelayStoragePath: StoragePath

    pub let RelayPrivatePath: PrivatePath

    pub let FeeCollectorStoragePath: StoragePath

    access(contract) let dataUpdaterPrivateBasePath: String

    access(contract) let symbolsRefData: {String: RefData}

    pub let e18: UInt256

    pub let e9: UInt256

    access(contract) let payments: FungibleToken.Vault

    access(contract) var fee: UFix64
}
```

The Flow blockchain contract for the Band Protocol Oracle.
https://docs.bandchain.org/
## Interfaces
    
### `OracleAdmin`

```cadence
pub resource interface OracleAdmin {
}
```
Resources
Admin only operations.

[More...](BandOracle_OracleAdmin.md)

---
    
### `DataUpdater`

```cadence
pub resource interface DataUpdater {
}
```
Relayer operations.

[More...](BandOracle_DataUpdater.md)

---
## Structs & Resources

### `RefData`

```cadence
pub struct RefData {

    pub var rate: UInt64

    pub var timestamp: UInt64

    pub var requestID: UInt64
}
```
Structs
Structure for storing any symbol USD-rate.

[More...](BandOracle_RefData.md)

---

### `ReferenceData`

```cadence
pub struct ReferenceData {

    pub var integerE18Rate: UInt256

    pub var fixedPointRate: UFix64

    pub var baseTimestamp: UInt64

    pub var quoteTimestamp: UInt64
}
```
Structure for consuming data as quote / base symbols.

[More...](BandOracle_ReferenceData.md)

---

### `BandOracleAdmin`

```cadence
pub resource BandOracleAdmin {
}
```
The `BandOracleAdmin` will be created on the contract deployment, and will allow
the own admin to manage the oracle and the relayers to update prices on it.

[More...](BandOracle_BandOracleAdmin.md)

---

### `Relay`

```cadence
pub resource Relay {

    priv let updaterCapability: Capability<&{DataUpdater}>
}
```
The resource that will allow an account to make quote updates

[More...](BandOracle_Relay.md)

---

### `FeeCollector`

```cadence
pub resource FeeCollector {
}
```
The resource that allows the maintainer account to charge a fee for the use of the oracle.

[More...](BandOracle_FeeCollector.md)

---
## Functions

### `updateRefData()`

```cadence
fun updateRefData(symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64, relayerID: UInt64)
```
Functions
Aux access(contract) functions
Auxiliary private function for the `OracleAdmin` to update the rates.

Parameters:
  - symbolsRates : _Set of symbols and corresponding usd rates to update._
  - resolveTime : _The registered time for the rates._
  - requestID : _The Band Protocol request ID._
  - relayerID : _The ID of the relayer carrying the update._

---

### `forceUpdateRefData()`

```cadence
fun forceUpdateRefData(symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64, relayerID: UInt64)
```
Auxiliary private function for the `OracleAdmin` to force update the rates.

Parameters:
  - symbolsRates : _Set of symbols and corresponding usd rates to update._
  - resolveTime : _The registered time for the rates._
  - requestID : _The Band Protocol request ID._
  - relayerID : _The ID of the relayer carrying the update._

---

### `removeSymbol()`

```cadence
fun removeSymbol(symbol: String)
```
Auxiliary private function for removing a stored symbol

Parameters:
  - symbol : _The string representing the symbol to delete_

---

### `_getRefData()`

```cadence
fun _getRefData(symbol: String): RefData?
```
Auxiliary private function for checking and retrieving data for a given symbol.

Parameters:
  - symbol : _String representing a symbol._

Returns: Optional `RefData` struct if there is any quote stored for the requested symbol.

---

### `calculateReferenceData()`

```cadence
fun calculateReferenceData(baseRefData: RefData, quoteRefData: RefData): ReferenceData
```
Private function that calculates the reference data between two base and quote symbols.

Parameters:
  - baseRefData : _Base ref data._
  - quoteRefData : _Quote ref data._

Returns: Calculated `ReferenceData` structure.

---

### `setFee()`

```cadence
fun setFee(fee: UFix64)
```
Private method for the `FeeCollector` to be able to set the fee for using the oracle

Parameters:
  - fee : _The amount of flow tokens to set as fee._

---

### `collectFees()`

```cadence
fun collectFees(): FungibleToken.Vault
```
Private method for the `FeeCollector` to be able to collect the fees from the contract vault.

Returns: A flow token vault with the collected fees so far.

---

### `createRelay()`

```cadence
fun createRelay(updaterCapability: Capability<&{DataUpdater}>): Relay
```
Public access functions.
Public method for creating a relay and become a relayer.

Parameters:
  - updaterCapability : _The capability pointing to the OracleAdmin resource needed to create the relay._

Returns: The new relay resource.

---

### `getUpdaterCapabilityNameFromAddress()`

```cadence
fun getUpdaterCapabilityNameFromAddress(relayer: Address): String
```
Auxiliary method to ensure that the formation of the capability name that
identifies data updater capability for relayers is done in a uniform way
by both admin and relayers.

Parameters:
  - relayer : _Address of the account who will be granted with a relayer._

Returns: The capability name.

---

### `getFee()`

```cadence
fun getFee(): UFix64
```
This function returns the current fee for using the oracle in Flow tokens.

Returns: The fee to be charged for every request made to the oracle.

---

### `getReferenceData()`

```cadence
fun getReferenceData(baseSymbol: String, quoteSymbol: String, payment: FungibleToken.Vault): ReferenceData
```
The entry point for consumers to query the oracle in exchange of a fee.

Parameters:
  - baseSymbol : _String representing base symbol._
  - quoteSymbol : _String representing quote symbol._
  - payment : _Flow token vault containing the service fee._

Returns: The `ReferenceData` containing the requested data.

---

### `e18ToFixedPoint()`

```cadence
fun e18ToFixedPoint(rate: UInt256): UFix64
```
Turn scientific notation numbers as `UInt256` multiplied by e8 into `UFix64`
fixed point numbers. Exceptionally large integer rates may lose some precision
when converted to a decimal number.

Parameters:
  - rate : _The symbol rate as an integer._

Returns: The symbol rate as a decimal.

---
## Events

### `BandOracleSymbolsUpdated`

```cadence
pub event BandOracleSymbolsUpdated(symbols: [String], relayerID: UInt64, requestID: UInt64)
```

---

### `BandOracleSymbolRemoved`

```cadence
pub event BandOracleSymbolRemoved(symbol: String)
```

---
