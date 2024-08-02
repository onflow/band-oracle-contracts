import "BandOracle"

transaction(relayer: Address) {
    prepare(acct: auth(BorrowValue)&Account){
        let oracleAdminRef = acct.storage.borrow<&{BandOracle.OracleAdmin}>(from: BandOracle.OracleAdminStoragePath)
            ?? panic("Can't borrow a reference to the Oracle Admin")
        // Unlink capability linked for that relayer address      
        acct.unlink(oracleAdminRef.getUpdaterCapabilityPathFromAddress(relayer: relayer))
    }
}