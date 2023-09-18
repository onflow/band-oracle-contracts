import BandOracle from "./../../contracts/BandOracle.cdc"

// This would create new data updater resources and publish a capability to
// them to the account meant to create a Relay resource

transaction(relayerAddress: Address) {
    prepare(acct: AuthAccount){
        // Get the capability to the oracle admin resource
        let adminCap = 
            acct.getCapability<&BandOracle.OracleAdmin>(BandOracle.OracleAdminPrivatePath)
        // Try to borrow a reference to the admin resource from the capability
        let oracleAdminRef = adminCap.borrow() 
            ?? panic("Can't borrow oracle admin resource")
        // Create a new data updater resource using the admin reference
        let refDataUpdater <- 
            oracleAdminRef.createRefDataUpdater(entitledRelayer: relayerAddress)
        // Create a new storage path for the updater using its uuid
        let storagePathString = 
            BandOracle.dataUpdaterStorageBasePath.concat(refDataUpdater.uuid.toString())
        let refDataUpdaterStoragePath = 
            StoragePath(identifier: storagePathString) 
            ?? panic("Error while creating data updater storage path")
        // Create a fresh private path for the updater capability using its uuid
        let privatePathString = 
            BandOracle.dataUpdaterPrivateBasePath.concat(refDataUpdater.uuid.toString())
        let refDataUpdaterPrivatePath = 
            PrivatePath(identifier: privatePathString) 
            ?? panic("Error while creating data updater capability private path")
        // Save the updater resource into the admin account
        acct.save(<- refDataUpdater, to: refDataUpdaterStoragePath)
        // Create a private capability linked to that resource
        let dataUpdaterCapability = 
            acct.link<&{BandOracle.DataUpdater}>
            (refDataUpdaterPrivatePath, target: refDataUpdaterStoragePath)
            ?? panic ("Data Updater capability creation failed")
        // Publish that capability for the entitled address
        acct.inbox.publish(dataUpdaterCapability, 
                        name: BandOracle.dataUpdaterPrivateBasePath.concat(relayerAddress.toString()), 
                        recipient: relayerAddress)
    }
}