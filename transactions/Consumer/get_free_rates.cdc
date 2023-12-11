import "BandOracle"
import "FlowToken"

transaction (baseSymbol: String, quoteSymbol: String) {

    prepare (acct: AuthAccount){
        if (BandOracle.getFee() > 0.0) {
            panic("Oracle queries require to pay a fee")
        }
    }

    execute {
        log(BandOracle.getReferenceData (baseSymbol: baseSymbol, quoteSymbol: quoteSymbol, payment: <- FlowToken.createEmptyVault()))
    }

}