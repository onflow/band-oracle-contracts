import BandOracle from "./../../contracts/BandOracle.cdc"

transaction (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
    let relayRef: &BandOracle.Relay

    prepare (acct: AuthAccount){
        let relayCapability = 
            acct.getCapability<&BandOracle.Relay>(BandOracle.RelayPrivatePath)
        self.relayRef = relayCapability.borrow()
            ?? panic ("Cannot borrow reference to relay resource")
    }

    execute {
        self.relayRef.relayRates(symbolsRates: symbolsRates, resolveTime: resolveTime, requestID: requestID)
    }
}