///
/// Contract that stores oracle prices allowing oracle to update them
///
pub contract BandOracle {
    
    ///
    /// Paths
    ///

    // Admin resource storage path
    pub let BandOracleAdminStoragePath: StoragePath

    ///
    /// Contract level fields
    ///
    
    // Mapping from symbol to data struct
    access(contract) let symbolsRefData: {String: RefData}

    ///
    /// Events
    ///

    //
    pub event NewRelayerCreated()
    
    //
    pub event RelayerAuthorised()
    
    //
    pub event RelayerDismissed()
    
    //
    pub event RefDataUpdated()

    ///
    /// Data Structs
    /// 
    
    //
    pub struct RefData {
        // USD-rate, multiplied by 1e9.
        pub var rate: UInt64
        // UNIX epoch when data is last resolved. 
        pub var timestamp: UInt64
        // BandChain request identifier for this data.
        pub var requestID: UInt64

        init(rate: UInt64, timestamp: UInt64, requestID: UInt64) {
            self.rate = rate
            self.timestamp = timestamp
            self.requestID = requestID
        }
    }

    ///
    /// Resources
    ///

    ///
    ///
    pub resource RelayerAdministrator {

        // This would create new data updater resources and publish a capability to
        // them to the account meant to create a Relay resource

        // It will also provide a mechanism to unlink that capability and delete the 
        // associated updater resource in case a certain Relayer needs to be 
        // unauthorized

    }

    ///
    ///
    pub resource interface DataUpdater {
        pub fun updateData (symbolsRates: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64)
    }

    ///
    ///
    pub resource RefDataUpdater: DataUpdater {
        pub fun updateData (symbolsRates: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64){
            BandOracle.updateRefData(symbolsRates: symbolsRates, resolveTime: resolveTime, 
                                    requestID: requestID)
        }
    }    

    ///
    ///
    pub resource Relay {
        
        // Capability linked to the assigned updater resource
        access(self) let updaterCapability: Capability<&{DataUpdater}>
    
        pub fun relay (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64){

        }

        init(updaterCapability: Capability<&{DataUpdater}>){
            self.updaterCapability = updaterCapability
        }
    }

    ///
    /// Contract functions
    ///

    ///
    ///
    access(contract) fun updateRefData (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {

    }

    ///
    ///
    access(contract) fun _getRefData (symbol: String): RefData?{
        return self.symbolsRefData[symbol]
    }

    ///
    ///
    pub fun getReferenceData (baseSymbol: String, quoteSymbol: String): RefData?{
        return self.symbolsRefData[baseSymbol]
    }

    ///
    ///
    pub fun createRelay (updaterCapability: Capability<&{DataUpdater}>): @Relay {
        return <- create Relay(updaterCapability: updaterCapability)
    }

    ///
    ///
    init() {
        self.BandOracleAdminStoragePath = /storage/BandOracleAdmin
        self.account.save(<- create RelayerAdministrator(), to: self.BandOracleAdminStoragePath)
        self.symbolsRefData = {}
    }
}