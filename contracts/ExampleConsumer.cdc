import "BandOracle"
import "FungibleToken"

// Example contract showing how to use the Band Protocol Oracle
pub contract ExampleConsumer {

    // Field that will store the Flow price in Bitcoin
    pub var flowBTC: BandOracle.ReferenceData?

    // Public function that can be used for paying the fee and update the Flow token price on the contract
    pub fun queryFlowBtcData (payment: @FungibleToken.Vault) {
        ExampleConsumer.flowBTC = BandOracle.getReferenceData(baseSymbol: "BTC", quoteSymbol: "FLOW", payment: <- payment)
    }

    // Public function for checking the updated price
    pub fun getFlowBtcData (): BandOracle.ReferenceData? {
        return self.flowBTC
    }

    init () {
        self.flowBTC = nil
    }
}