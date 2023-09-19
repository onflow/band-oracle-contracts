import BandOracle from "./../../contracts/BandOracle.cdc"

transaction(relayerAddress: Address) {
    prepare(acct: AuthAccount){
        // Create a fresh private path for the updater capability using relayer address
        let privatePathString = 
            BandOracle.dataUpdaterPrivateBasePath.concat(relayerAddress.toString())
        let dataUpdaterPrivatePath = 
            PrivatePath(identifier: privatePathString) 
            ?? panic("Error while creating data updater capability private path")
        // Link the custom private capability to the oracle admin resource
        let dataUpdaterCapability = 
            acct.link<&{BandOracle.DataUpdater}>
            (dataUpdaterPrivatePath, target: BandOracle.OracleAdminStoragePath)
            ?? panic ("Data Updater capability creation failed")
        // Publish that capability for the entitled address
        acct.inbox.publish(dataUpdaterCapability, 
            name: BandOracle.dataUpdaterPrivateBasePath.concat(relayerAddress.toString()), 
            recipient: relayerAddress)
    }
}