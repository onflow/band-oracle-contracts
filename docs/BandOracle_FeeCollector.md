# Resource `FeeCollector`

```cadence
pub resource FeeCollector {
}
```

The resource that allows the maintainer account to charge a fee for the use of the oracle.
## Functions

### `setFee()`

```cadence
fun setFee(fee: UFix64)
```
Sets the fee in Flow tokens for the oracle use.

Parameters:
  - fee : _The amount of Flow tokens._

---

### `collectFees()`

```cadence
fun collectFees(): FungibleToken.Vault
```
Extracts the fees from the contract's vault.

Returns: A vault containing the funds obtained for the oracle use.

---
