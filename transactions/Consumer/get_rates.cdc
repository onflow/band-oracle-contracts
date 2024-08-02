import "BandOracle"
import "FlowToken"
import "FungibleToken"

transaction (baseSymbol: String, quoteSymbol: String) {
    
    let payment: @{FungibleToken.Vault}

    prepare (acct: auth(Storage)&Account){

        let vault <- acct.storage.load<@FlowToken.Vault>(from: /storage/flowTokenVault) ??
            panic("Cannot load account flow vault")
        
        self.payment <- vault.withdraw(amount: BandOracle.getFee())
        
        acct.storage.save(<- vault, to: /storage/flowTokenVault)

    }

    execute {
        log(BandOracle.getReferenceData (baseSymbol: baseSymbol, quoteSymbol: quoteSymbol, payment: <- self.payment))
    }

}