# Resource Interface `OracleAdmin`

```cadence
pub resource interface OracleAdmin {
}
```

Resources
Admin only operations.
## Functions

### `getUpdaterCapabilityPathFromAddress()`

```cadence
fun getUpdaterCapabilityPathFromAddress(relayer: Address): PrivatePath
```

---

### `removeSymbol()`

```cadence
fun removeSymbol(symbol: String)
```

---

### `createNewFeeCollector()`

```cadence
fun createNewFeeCollector(): BandOracle.FeeCollector
```

---
