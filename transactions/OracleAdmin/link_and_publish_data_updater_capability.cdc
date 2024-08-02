import "BandOracle"

transaction(relayer: Address) {
    prepare(acct: auth(BorrowValue)&Account){
        let oracleAdminRef = acct.storage.borrow<&{BandOracle.OracleAdmin}>(from: BandOracle.OracleAdminStoragePath)
            ?? panic("Can't borrow a reference to the Oracle Admin")
        let dataUpdaterPrivatePath = oracleAdminRef.getUpdaterCapabilityPathFromAddress(relayer: relayer)
        // Link the custom private capability to the oracle admin resource
        let dataUpdaterCapability = 
            acct.link<&{BandOracle.DataUpdater}>
            (dataUpdaterPrivatePath, target: BandOracle.OracleAdminStoragePath)
            ?? panic ("Data Updater capability creation failed")
        // Publish that capability for the entitled address
        acct.inbox.publish(dataUpdaterCapability, 
            name: BandOracle.getUpdaterCapabilityNameFromAddress (relayer: relayer), 
            recipient: relayer)
    }
}