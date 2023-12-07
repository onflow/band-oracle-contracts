import "BandOracle"
import "FlowToken"

transaction (baseSymbol: String, quoteSymbol: String) {

    prepare (){
        if (BandOracle.getFee() > 0.0) {
            panic("Oracle queries require to pay a fee")
        }
    }

    execute {
        BandOracle.getReferenceData (baseSymbol: baseSymbol, quoteSymbol: quoteSymbol, payment: <- FlowToken.createEmptyVault())
    }

}