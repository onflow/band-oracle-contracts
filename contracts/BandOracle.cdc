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
    
    // Emitted by a relayer when it updates a set of symbols
    pub event BandOracleSymbolsUpdated(symbols: [String], relayerID: UInt64, requestID: UInt64)

    ///
    /// Structs
    /// 
    
    // Struct for storing market data
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

    // Struct for consuming market data
    pub struct ReferenceData {
        // Base / quote symbols rate
        pub var rate: UInt256
        // UNIX epoch when base data is last resolved. 
        pub var baseTimestamp: UInt64
        // UNIX epoch when quote data is last resolved. 
        pub var quoteTimestamp: UInt64

        init(rate: UInt256, baseTimestamp: UInt64, quoteTimestamp: UInt64) {
            self.rate = rate
            self.baseTimestamp = baseTimestamp
            self.quoteTimestamp = quoteTimestamp
        }
    }


    ///
    /// Resources
    ///

    pub resource interface OracleAdmin {
        pub fun getUpdaterCapabilityPathFromAddress (relayer: Address): PrivatePath
    }

    ///
    ///
    pub resource interface DataUpdater {
        pub fun updateData (symbolsRates: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64, relayerID: UInt64)
        pub fun forceUpdateData (symbolsRates: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64, relayerID: UInt64)
    }

    ///
    ///
    pub resource BandOracleAdmin: OracleAdmin, DataUpdater {

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
                            requestID: UInt64, relayerID: UInt64) {
            BandOracle.updateRefData(symbolsRates: symbolsRates, resolveTime: resolveTime, 
                                    requestID: requestID, relayerID: relayerID)
        }

        // OracleAdmin and entitled relayers can call this method to force update rates
        pub fun forceUpdateData (symbolsRates: {String: UInt64}, resolveTime: UInt64, 
                                requestID: UInt64, relayerID: UInt64) {
            BandOracle.forceUpdateRefData(symbolsRates: symbolsRates, resolveTime: resolveTime, 
                                    requestID: requestID, relayerID: relayerID)
        }
        
    }

    ///
    ///
    pub resource Relay {
        
        // Capability linked to the OracleAdmin allowing relayers to relay rate updates
        access(self) let updaterCapability: Capability<&{DataUpdater}>
    
        pub fun relayRates (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
            let updaterRef = self.updaterCapability.borrow() 
                ?? panic ("Can't borrow reference to data updater while processing request ".concat(requestID.toString()))
            updaterRef.updateData(symbolsRates: symbolsRates, resolveTime: resolveTime, requestID: requestID, relayerID: self.uuid)
        }

        pub fun forceRelayRates (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
            let updaterRef = self.updaterCapability.borrow() 
                ?? panic ("Can't borrow reference to data updater while processing request ".concat(requestID.toString()))
            updaterRef.forceUpdateData(symbolsRates: symbolsRates, resolveTime: resolveTime, requestID: requestID, relayerID: self.uuid)
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
    access(contract) fun updateRefData (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64, relayerID: UInt64) {
        let updatedSymbols: [String] = []
        // For each symbol rate relayed
        for symbol in symbolsRates.keys {
            // If the symbol hasn't stored rates yet, or the stored records are older
            // than the new relayed rates
            if (BandOracle.symbolsRefData[symbol] == nil ) ||
                (BandOracle.symbolsRefData[symbol]!.timestamp < resolveTime) {
                // Store the relayed rate
                BandOracle.symbolsRefData[symbol] = 
                    RefData(rate: symbolsRates[symbol]!, timestamp: resolveTime, requestID: requestID)
                updatedSymbols.append(symbol)
            }
        }
        emit BandOracleSymbolsUpdated(symbols: updatedSymbols, relayerID: relayerID, requestID: requestID)
    }

    ///
    ///
    access(contract) fun forceUpdateRefData (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64, relayerID: UInt64) {
        // For each symbol rate relayed, store it no matter what was the previous
        // records for it
        for symbol in symbolsRates.keys {
            BandOracle.symbolsRefData[symbol] = 
                RefData(rate: symbolsRates[symbol]!, timestamp: resolveTime, requestID: requestID)
        }
        emit BandOracleSymbolsUpdated(symbols: symbolsRates.keys, relayerID: relayerID, requestID: requestID)
    }

    ///
    ///
    access(contract) fun removeSymbol (symbol: String) {
        BandOracle.symbolsRefData[symbol] = nil
    }

    ///
    ///
    access(contract) fun _getRefData (symbol: String): RefData? {
        if (symbol == "USD") {
            return RefData(rate: 1000000000, timestamp: UInt64(getCurrentBlock().timestamp), requestID: 0)
        } else {
            return self.symbolsRefData[symbol] ?? nil
        }
    }

    ///
    ///
    pub fun getReferenceData (baseSymbol: String, quoteSymbol: String): ReferenceData? {
        let baseRefData = BandOracle._getRefData(symbol: baseSymbol)
        let quoteRefData = BandOracle._getRefData(symbol: quoteSymbol)
        let backToDecimalFactor: UInt256 = 1000000000000000000
        if (baseRefData == nil || quoteRefData == nil) {
            return nil
        } else {
            let rate = UInt256((UInt256(baseRefData!.rate) * backToDecimalFactor) / UInt256(quoteRefData!.rate)) 
            return ReferenceData (rate: rate, 
                            baseTimestamp: baseRefData!.timestamp,
                            quoteTimestamp: quoteRefData!.timestamp)
        }
        
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
        self.account.save(<- create BandOracleAdmin(), to: self.OracleAdminStoragePath)
        self.account.link<&{OracleAdmin}>(self.OracleAdminPrivatePath, target: self.OracleAdminStoragePath)
        self.symbolsRefData = {}
        // Create a relayer on the admin account so the relay methods are never accessed directly.
        // The admin could decide to build a transaction borrowing the whole BandOracleAdmin
        // resource and call updateData methods bypassing relayData methods but we are explicitly
        // discouraging that by giving the admin a regular relay resource on contract deployment.
        let oracleAdminRef = self.account.borrow<&{OracleAdmin}>(from: BandOracle.OracleAdminStoragePath)
            ?? panic("Can't borrow a reference to the Oracle Admin")
        let dataUpdaterPrivatePath = oracleAdminRef.getUpdaterCapabilityPathFromAddress(relayer: self.account.address)
        self.account.link<&{BandOracle.DataUpdater}>(dataUpdaterPrivatePath, target: BandOracle.OracleAdminStoragePath)
            ?? panic ("Data Updater capability for admin creation failed")
        let updaterCapability = self.account.getCapability<&{BandOracle.DataUpdater}>(dataUpdaterPrivatePath)
        let relayer <- BandOracle.createRelay(updaterCapability: updaterCapability)
        self.account.save(<- relayer, to: BandOracle.RelayStoragePath)
        self.account.link<&BandOracle.Relay>(BandOracle.RelayPrivatePath, target: BandOracle.RelayStoragePath)
    }
}