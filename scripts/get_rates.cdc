import BandOracle from "./../contracts/BandOracle.cdc"

pub fun main(baseSymbol: String, quoteSymbol: String): BandOracle.ReferenceData? {
    return BandOracle.getReferenceData (baseSymbol: baseSymbol, quoteSymbol: quoteSymbol)
}

