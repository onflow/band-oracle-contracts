import "BandOracle"
import "FlowToken"
import "FungibleToken"

transaction (baseSymbol: String, quoteSymbol: String) {
    
    let payment: @{FungibleToken.Vault}

    prepare (acct: auth(BorrowValue)&Account){

        let vault <- acct.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault) ??
            panic("Cannot borrow reference to signer's FLOW vault")
        
        self.payment <- vault.withdraw(amount: BandOracle.getFee())
        
        acct.storage.save(<- vault, to: /storage/flowTokenVault)

    }

    execute {
        log(BandOracle.getReferenceData (baseSymbol: baseSymbol, quoteSymbol: quoteSymbol, payment: <- self.payment))
    }

}