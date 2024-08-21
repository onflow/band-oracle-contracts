import "BandOracle"
import "FlowToken"
import "FungibleToken"

transaction (baseSymbol: String, quoteSymbol: String) {
    
    let payment: @{FungibleToken.Vault}

    prepare (acct: auth(BorrowValue)&Account){

        let vaultRef = acct.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault) ??
            panic("Cannot borrow reference to signer's FLOW vault")
        
        self.payment <- vaultRef.withdraw(amount: BandOracle.getFee())

    }

    execute {
        log(BandOracle.getReferenceData (baseSymbol: baseSymbol, quoteSymbol: quoteSymbol, payment: <- self.payment))
    }

}