# Struct `ReferenceData`

```cadence
pub struct ReferenceData {

    pub var integerE18Rate: UInt256

    pub var fixedPointRate: UFix64

    pub var baseTimestamp: UInt64

    pub var quoteTimestamp: UInt64
}
```

Structure for consuming data as quote / base symbols.

### Initializer

```cadence
init(rate: UInt256, baseTimestamp: UInt64, quoteTimestamp: UInt64)
```


