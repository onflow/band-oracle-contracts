import "BandOracle"

pub fun main(baseSymbol: String, quoteSymbol: String): BandOracle.ReferenceData? {
    return BandOracle.getReferenceData (baseSymbol: baseSymbol, quoteSymbol: quoteSymbol)
}