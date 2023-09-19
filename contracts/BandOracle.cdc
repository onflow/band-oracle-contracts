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
    pub let dataUpdaterPrivateBasePath: String

    // Mapping from symbol to data struct
    access(contract) let symbolsRefData: {String: RefData}
    // Hay que ver como sabemos que relay desconectar
    access(contract) let relayersUpdaterIdentifier: {Address: UInt64}

    ///
    /// Events
    ///
    
    //
    pub event RefDataUpdated()

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
        pub fun updateData (symbolsRate: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64)
    }
    ///
    ///
    pub resource OracleAdmin: DataUpdater {

/*
        // mierda puta esto hay que cambiarlo x algo que publique la capability?
        pub fun authorizeRelayer (authorizedRelayer: Address): Capability<&{DataUpdater}> {









            BandOracle.relayersUpdaterIdentifier[entitledRelayer] = refDataUpdater.uuid
            emit NewRefDataUpdaterCreated(entitledRelayer: entitledRelayer, updaterID: refDataUpdater.uuid)

            return dataUpdaterCapability
        }
*/
        pub fun revokeRelayer (revokedRelayer: Address) {


        }

        //maybe we can have a field holding the entitled relayers
        // maybe even authorising / revoking leaves here rather than on the admin?
        // maybe this is da admin
        pub fun updateData (symbolsRate: {String: UInt64}, resolveTime: UInt64, 
                            requestID: UInt64){
            BandOracle.updateRefData(symbolsRate: symbolsRate, resolveTime: resolveTime, 
                                    requestID: requestID)
        }

    }

    ///
    ///
    pub resource Relay {
        
        // Capability linked to the assigned updater resource
        access(self) let updaterCapability: Capability<&{DataUpdater}>
    
        pub fun relayRates (symbolsRates: {String: UInt64}, resolveTime: UInt64, requestID: UInt64){

        }

        init(updaterCapability: Capability<&{DataUpdater}>){
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
    access(contract) fun updateRefData (symbolsRate: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
        // Modify contract level field dictionary that stores rates
    }

    ///
    ///
    access(contract) fun forceUpdateRefData (symbolsRate: {String: UInt64}, resolveTime: UInt64, requestID: UInt64) {
        // Modify contract level field dictionary that stores rates even if resolveTime is older
    }

    ///
    ///
    access(contract) fun removeSymbol (symbol: String){
        // Delete symbol entry on the contract dictionary
    }

    ///
    ///
    access(contract) fun _getRefData (symbol: String): RefData?{
        return self.symbolsRefData[symbol]
    }

    ///
    ///
    pub fun getReferenceData (baseSymbol: String, quoteSymbol: String): RefData?{
        return nil
    }

    ///
    ///
    pub fun createRelay (updaterCapability: Capability<&{DataUpdater}>): @Relay {
        return <- create Relay(updaterCapability: updaterCapability)
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
        self.relayersUpdaterIdentifier = {}
    }
}