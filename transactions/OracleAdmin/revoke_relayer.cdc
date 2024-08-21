import "BandOracle"

transaction(relayer: Address) {
    prepare(acct: auth(BorrowValue, GetStorageCapabilityController)&Account){
        let oracleAdminRef = acct.storage.borrow<&{BandOracle.OracleAdmin}>(from: BandOracle.OracleAdminStoragePath)
            ?? panic("Can't borrow a reference to the Oracle Admin")

        // Get the capability ID for the relayer address
        if let capabilityID = oracleAdminRef.getUpdaterCapabilityIDFromAddress(relayer: relayer){
            let controller = acct.capabilities.storage.getController(byCapabilityID: capabilityID) ??
                panic("Can't get relayer's data updater capability controller")
            controller.delete()
            let revokedRelayer =oracleAdminRef.revokeRelayer(relayer: relayer)
            log(revokedRelayer)
        } else {
            panic("Address is not a relayer")
        }

    }
}