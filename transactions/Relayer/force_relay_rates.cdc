import "BandOracle"

transaction (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
    let relayRef: &BandOracle.Relay

    prepare (acct: auth(BorrowValue)&Account){
        // Get a reference to the relayer resource from storage
        self.relayRef = acct.storage.borrow<&BandOracle.Relay>(from: BandOracle.RelayStoragePath) ??
            panic("Cannot borrow reference to relay resource")
    }

    execute {
        // Call the relayRates function exposed by the relayer resource
        self.relayRef.forceRelayRates(symbolsRates: symbolsRates, resolveTime: resolveTime, requestID: requestID)
    }
}