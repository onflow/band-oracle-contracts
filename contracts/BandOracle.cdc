///
/// Contract that stores oracle prices allowing oracle to update them
///
pub contract BandOracle {
    
    ///
    /// Paths
    ///

    // OracleAdmin resource paths
    pub let OracleAdminStoragePath: StoragePath
    pub let OracleAdminPrivatePath: PrivatePath

    // Relay resource paths
    pub let RelayStoragePath: StoragePath
    pub let RelayPrivatePath: PrivatePath

    ///
    /// Fields
    ///
    
    /// Set a string as base private path for data updater capabilities
    access(contract) let dataUpdaterPrivateBasePath: String

    // Mapping from symbol to data struct
    access(contract) let symbolsRefData: {String: RefData}

    ///
    /// Events
    ///
    
    //
    pub event RefDataUpdated(symbols: [String], relayerID: UInt64, requestID: UInt64)

    ///
    /// Structs
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
    pub resource interface DataUpdater {
        pub fun updateData (symbolsRates: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64)
        pub fun forceUpdateData (symbolsRates: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64)
    }

    ///
    ///
    pub resource OracleAdmin: DataUpdater {

        ///
        /// Auxiliary method to ensure that the formation of the capability path that 
        /// identifies relayers is done in a uniform way
        ///
        pub fun getUpdaterCapabilityPathFromAddress (relayer: Address): PrivatePath {
            // Create the string that will form the private path concatenating the base
            // path and the relayer identifying address
            let privatePathString = 
                BandOracle.getUpdaterCapabilityNameFromAddress(relayer: relayer)
            // Attempt to create the private path using the identifier
            let dataUpdaterPrivatePath = 
                PrivatePath(identifier: privatePathString) 
                ?? panic("Error while creating data updater capability private path")
            return dataUpdaterPrivatePath
        }
        
        // OracleAdmin and entitled relayers can call this method to update rates
        pub fun updateData (symbolsRates: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64) {
            BandOracle.updateRefData(symbolsRates: symbolsRates, resolveTime: resolveTime, 
                                    requestID: requestID)
        }

        // OracleAdmin and entitled relayers can call this method to force update rates
        pub fun forceUpdateData (symbolsRates: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64) {
            BandOracle.forceUpdateRefData(symbolsRates: symbolsRates, resolveTime: resolveTime, 
                                    requestID: requestID)
        }
        
    }

    ///
    ///
    pub resource Relay {
        
        // Capability linked to the assigned updater resource
        access(self) let updaterCapability: Capability<&{DataUpdater}>
    
        pub fun relayRates (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
            let updaterRef = self.updaterCapability.borrow() 
                ?? panic ("Can't borrow reference to data updater while processing request ".concat(requestID.toString()))
            updaterRef.updateData(symbolsRates: symbolsRates, resolveTime: resolveTime, requestID: requestID)
            emit RefDataUpdated(symbols: symbolsRates.keys, relayerID: self.uuid, requestID: requestID)
        }

        pub fun forceRelayRates (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
            let updaterRef = self.updaterCapability.borrow() 
                ?? panic ("Can't borrow reference to data updater while processing request ".concat(requestID.toString()))

            emit RefDataUpdated(symbols: symbolsRates.keys, relayerID: self.uuid, requestID: requestID)
        }

        init(updaterCapability: Capability<&{DataUpdater}>) {
            self.updaterCapability = updaterCapability
            let updaterRef = self.updaterCapability.borrow() 
                ?? panic ("Can't borrow linked updater")
        }
    }

    ///
    /// Functions
    ///

    ///
    ///
    access(contract) fun updateRefData (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
        // For each symbol rate relayed
        for symbol in symbolsRates.keys {
            // If the symbol hasn't stored rates yet, or the stored records are older
            // than the new relayed rates
            if (BandOracle.symbolsRefData[symbol] == nil ) ||
                (BandOracle.symbolsRefData[symbol]!.timestamp < resolveTime) {
                // Store the relayed rate
                BandOracle.symbolsRefData[symbol] = 
                    RefData(rate: symbolsRates[symbol]!, timestamp: resolveTime, requestID: requestID)
            }
        }
    }

    ///
    ///
    access(contract) fun forceUpdateRefData (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
        // For each symbol rate relayed, store it no matter what was the previous
        // records for it
        for symbol in symbolsRates.keys {
            BandOracle.symbolsRefData[symbol] = 
                RefData(rate: symbolsRates[symbol]!, timestamp: resolveTime, requestID: requestID)
        }
    }

    ///
    ///
    access(contract) fun removeSymbol (symbol: String) {
        BandOracle.symbolsRefData[symbol] = nil
    }

    ///
    ///
    access(contract) fun _getRefData (symbol: String): RefData? {
        return self.symbolsRefData[symbol] ?? nil
    }

    ///
    ///
    pub fun getReferenceData (baseSymbol: String, quoteSymbol: String): RefData? {
        

        return nil
    }

    ///
    ///
    pub fun createRelay (updaterCapability: Capability<&{DataUpdater}>): @Relay {
        return <- create Relay(updaterCapability: updaterCapability)
    }

    ///
    /// Auxiliary method to ensure that the formation of the capability name that 
    /// identifies data updater capability for relayers is done in a uniform way
    /// by both admin and relayers
    ///
    pub fun getUpdaterCapabilityNameFromAddress (relayer: Address): String {
        // Create the string that will form the private path concatenating the base
        // path and the relayer identifying address
        let capabilityName = 
            BandOracle.dataUpdaterPrivateBasePath.concat(relayer.toString())
        return capabilityName
    }

    ///
    ///
    init() {
        self.OracleAdminStoragePath = /storage/BandOracleAdmin
        self.OracleAdminPrivatePath = /private/BandOracleAdmin
        self.RelayStoragePath = /storage/BandOracleRelay
        self.RelayPrivatePath = /private/BandOracleRelay
        self.dataUpdaterPrivateBasePath = "DataUpdater"
        self.account.save(<- create OracleAdmin(), to: self.OracleAdminStoragePath)
        self.account.link<&OracleAdmin>(self.OracleAdminPrivatePath, target: self.OracleAdminStoragePath)
        self.symbolsRefData = {}
    }
}