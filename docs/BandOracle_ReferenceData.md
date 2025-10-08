# Struct `ReferenceData`

```cadence
access(all) struct ReferenceData {

    access(all) var integerE18Rate: UInt256

    access(all) var fixedPointRate: UFix64

    access(all) var baseTimestamp: UInt64

    access(all) var quoteTimestamp: UInt64
}
```

Structure for consuming data as quote / base symbols.

### Initializer

```cadence
init(rate: UInt256, baseTimestamp: UInt64, quoteTimestamp: UInt64)
```


