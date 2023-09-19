import BandOracle from "./../../contracts/BandOracle.cdc"

transaction(relayerAddress: Address) {
    prepare(acct: AuthAccount){
        // Recreate the private path for the updater capability using relayer address
        let privatePathString = 
            BandOracle.dataUpdaterPrivateBasePath.concat(relayerAddress.toString())
        let dataUpdaterPrivatePath = 
            PrivatePath(identifier: privatePathString) 
            ?? panic("Error while creating data updater capability private path")
        // Unlink capability linked for that relayer address      
        acct.unlink(dataUpdaterPrivatePath)
    }
}