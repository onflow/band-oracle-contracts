# Resource `BandOracleAdmin`

```cadence
access(all) resource BandOracleAdmin {
}
```

The `BandOracleAdmin` will be created on the contract deployment, and will allow
the own admin to manage the oracle and the relayers to update prices on it.

Implemented Interfaces:
  - `OracleAdmin`
  - `DataUpdater`

## Functions

### `getUpdaterCapabilityPathFromAddress()`

```cadence
access(all) fun getUpdaterCapabilityPathFromAddress(relayer: Address): PrivatePath
```
Auxiliary method to ensure that the formation of the capability path that
identifies relayers is done in a uniform way.

Parameters:
  - relayer : _The entitled relayer account address_

---

### `removeSymbol()`

```cadence
access(all) fun removeSymbol(symbol: String)
```
Removes a symbol and its quotes from the contract storage.

Parameters:
  - symbol : _The string representing the symbol to be removed from the contract._

---

### `updateData()`

```cadence
access(all) fun updateData(symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64, relayerID: UInt64)
```
Relayers can call this method to update rates.

Parameters:
  - symbolsRates : _Set of symbols and corresponding usd rates to update._
  - resolveTime : _The registered time for the rates._
  - requestID : _The Band Protocol request ID._
  - relayerID : _The ID of the relayer carrying the update._

---

### `forceUpdateData()`

```cadence
access(all) fun forceUpdateData(symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64, relayerID: UInt64)
```
Relayers can call this method to force update rates.

Parameters:
  - symbolsRates : _Set of symbols and corresponding usd rates to update._
  - resolveTime : _The registered time for the rates._
  - requestID : _The Band Protocol request ID._
  - relayerID : _The ID of the relayer carrying the update._

---

### `createNewFeeCollector()`

```cadence
access(all) fun createNewFeeCollector(): FeeCollector
```
Creates a fee collector, meant to be called once after contract deployment
for storing the resource on the maintainer's account.

Returns: The `FeeCollector` resource

---
