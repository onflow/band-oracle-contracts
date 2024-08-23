import "BandOracle"

transaction(relayer: Address) {
    prepare(acct: auth(BorrowValue, PublishInboxCapability, IssueStorageCapabilityController)&Account){
        let oracleAdminRef = acct.storage.borrow<&{BandOracle.OracleAdmin}>(from: BandOracle.OracleAdminStoragePath)
            ?? panic("Can't borrow a reference to the Oracle Admin")
        
        // Issue the data updater capability (Is this needed to do every time you want to publish a capability?)
        let dataUpdaterCapability = 
            acct.capabilities.storage.issue<&{BandOracle.DataUpdater}>(BandOracle.OracleAdminStoragePath)

        // Store in contract the relayer capability ID
        oracleAdminRef.setRelayerCapabilityID(relayer: relayer, capabilityID: dataUpdaterCapability.id)
        
        // Publish that capability for the entitled address
        acct.inbox.publish(dataUpdaterCapability, 
            name: BandOracle.getUpdaterCapabilityNameFromAddress (relayer: relayer), 
            recipient: relayer)
    }
}