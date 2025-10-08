# Struct `RefData`

```cadence
access(all) struct RefData {

    access(all) var rate: UInt64

    access(all) var timestamp: UInt64

    access(all) var requestID: UInt64
}
```

Structs
Structure for storing any symbol USD-rate.

### Initializer

```cadence
init(rate: UInt64, timestamp: UInt64, requestID: UInt64)
```


