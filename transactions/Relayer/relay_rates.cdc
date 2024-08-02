import "BandOracle"

transaction (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
    let relayRef: &BandOracle.Relay

    prepare (acct: &Account){
        // Get a capability to the relayer resource
        let relayCapability = 
            acct.getCapability<&BandOracle.Relay>(BandOracle.RelayPrivatePath)
        // And borrow a reference to it
        self.relayRef = relayCapability.borrow()
            ?? panic ("Cannot borrow reference to relay resource")
    }

    execute {
        // Call the relayRates function exposed by the relayer resource
        self.relayRef.relayRates(symbolsRates: symbolsRates, resolveTime: resolveTime, requestID: requestID)
    }
}