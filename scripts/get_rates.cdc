import "BandOracle"

pub fun main(baseSymbol: String, quoteSymbol: String): BandOracle.ReferenceData? {
    return BandOracle.getFreeReferenceData (baseSymbol: baseSymbol, quoteSymbol: quoteSymbol)
}