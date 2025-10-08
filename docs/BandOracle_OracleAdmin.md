# Resource Interface `OracleAdmin`

```cadence
access(all) resource interface OracleAdmin {
}
```

Resources
Admin only operations.
## Functions

### `setRelayerCapabilityID()`

```cadence
access(all) fun setRelayerCapabilityID(relayer: Address, capabilityID: UInt64)
```

---

### `removeRelayerCapabilityID()`

```cadence
access(all) fun removeRelayerCapabilityID(relayer: Address)
```

---

### `getUpdaterCapabilityIDFromAddress()`

```cadence
access(all) fun getUpdaterCapabilityIDFromAddress(relayer: Address): UInt64?
```

---

### `removeSymbol()`

```cadence
access(all) fun removeSymbol(symbol: String)
```

---

### `createNewFeeCollector()`

```cadence
access(all) fun createNewFeeCollector(): BandOracle.FeeCollector
```

---
