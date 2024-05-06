import "BandOracle"

transaction (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
    let relayRef: &BandOracle.Relay

    prepare (acct: &Account){
        // Borrow a capability to the relayer resource
        self.relayRef = acct.capabilities.borrow<&{BandOracle.Relay}>(BandOracle.RelayPrivatePath)
            ?? panic ("Cannot borrow reference to relay resource")
    }

    execute {
        // Call the relayRates function exposed by the relayer resource
        self.relayRef.forceRelayRates(symbolsRates: symbolsRates, resolveTime: resolveTime, requestID: requestID)
    }
}