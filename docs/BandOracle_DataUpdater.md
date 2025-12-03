# Resource Interface `DataUpdater`

```cadence
access(all) resource interface DataUpdater {
}
```

Relayer operations.
## Functions

### `updateData()`

```cadence
access(all) fun updateData(
    symbolsRates: {String: UInt64},
    resolveTime: UInt64,
    requestID: UInt64,
    relayerID: UInt64
)
```

---

### `forceUpdateData()`

```cadence
access(all) fun forceUpdateData(
    symbolsRates: {String: UInt64},
    resolveTime: UInt64,
    requestID: UInt64,
    relayerID: UInt64
)
```

---
