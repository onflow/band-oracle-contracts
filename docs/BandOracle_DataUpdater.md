# Resource Interface `DataUpdater`

```cadence
pub resource interface DataUpdater {
}
```

Relayer operations.
## Functions

### `updateData()`

```cadence
fun updateData(symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64, relayerID: UInt64)
```

---

### `forceUpdateData()`

```cadence
fun forceUpdateData(symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64, relayerID: UInt64)
```

---
