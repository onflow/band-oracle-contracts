import BandOracle from "./../../contracts/BandOracle.cdc"

// This would create new data updater resources and publish a capability to
// them to the account meant to create a Relay resource

transaction(relayerAddress: Address) {
    prepare(acct: AuthAccount){
        let adminCap = 
            acct.getCapability<&BandOracle.OracleAdmin>(BandOracle.OracleAdminPrivatePath)
        let oracleAdminRef = adminCap.borrow() 
            ?? panic("Can't borrow oracle admin resource")
        let refDataUpdater <- oracleAdminRef.createRefDataUpdater()
        let storagePathString = 
            BandOracle.dataUpdaterStorageBasePath.concat(refDataUpdater.uuid.toString())
        let refDataUpdaterStoragePath = 
            StoragePath(identifier: storagePathString) 
            ?? panic("Error while creating data updater storage path")
        let privatePathString = 
            BandOracle.dataUpdaterPrivateBasePath.concat(refDataUpdater.uuid.toString())
        let refDataUpdaterPrivatePath = 
            PrivatePath(identifier: privatePathString) 
            ?? panic("Error while creating data updater capability private path")
        acct.save(<- refDataUpdater, to: refDataUpdaterStoragePath)
        let dataUpdaterCapability = 
            acct.link<&{BandOracle.DataUpdater}>
            (refDataUpdaterPrivatePath, target: refDataUpdaterStoragePath)
            ?? panic ("Data Updater capability creation failed")
        acct.inbox.publish(dataUpdaterCapability, 
                        name: BandOracle.dataUpdaterPrivateBasePath.concat(relayerAddress.toString()), 
                        recipient: relayerAddress)
    }
}