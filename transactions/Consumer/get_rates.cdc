import "BandOracle"
import "FungibleToken"
import "FlowToken"

transaction (baseSymbol: String, quoteSymbol: String) {

    let feePayment: @FungibleToken.Vault

    prepare (acct: AuthAccount){
        self.feePayment <- FlowToken.createEmptyVault()
        let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) ??
            panic("Cannot borrow consumer's flow vault")
        self.feePayment.deposit(from: <- vaultRef.withdraw(amount: BandOracle.getFee()))
    }

    execute {
        BandOracle.getReferenceData (baseSymbol: baseSymbol, quoteSymbol: quoteSymbol, payment: <- self.feePayment)
    }

}