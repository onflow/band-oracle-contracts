import "BandOracle"

transaction(relayer: Address) {
    prepare(acct: AuthAccount){
        let oracleAdminRef = acct.capabilities.borrow<&{BandOracle.OracleAdmin}>(from: BandOracle.OracleAdminStoragePath)
            ?? panic("Can't borrow a reference to the Oracle Admin")

        // Unlink capability linked for that relayer address      
        acct.capabilities.unpublish(oracleAdminRef.getUpdaterCapabilityPathFromAddress(relayer: relayer))
    }
}