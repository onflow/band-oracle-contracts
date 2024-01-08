# Resource `Relay`

```cadence
pub resource Relay {

    priv let updaterCapability: Capability<&{DataUpdater}>
}
```

The resource that will allow an account to make quote updates

### Initializer

```cadence
init(updaterCapability: Capability<&{DataUpdater}>)
```


## Functions

### `relayRates()`

```cadence
fun relayRates(symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64)
```
Relay updated rates to the Oracle Admin

Parameters:
  - symbolsRates : _Set of symbols and corresponding usd rates to update._
  - resolveTime : _The registered time for the rates._
  - requestID : _The Band Protocol request ID._

---

### `forceRelayRates()`

```cadence
fun forceRelayRates(symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64)
```
Relay updated rates to the Oracle Admin forcing the update of the symbols even if the `resolveTime` is older than the last update.

Parameters:
  - symbolsRates : _Set of symbols and corresponding usd rates to update._
  - resolveTime : _The registered time for the rates._
  - requestID : _The Band Protocol request ID._

---
