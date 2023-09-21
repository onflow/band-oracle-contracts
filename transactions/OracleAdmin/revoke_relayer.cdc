import BandOracle from "./../../contracts/BandOracle.cdc"

transaction(relayer: Address) {
    prepare(acct: AuthAccount){
        let oracleAdminRef = acct.borrow<&BandOracle.OracleAdmin>(from: BandOracle.OracleAdminStoragePath)
            ?? panic("Can't borrow a reference to the Oracle Admin")
        // Unlink capability linked for that relayer address      
        acct.unlink(oracleAdminRef.getUpdaterCapabilityPathFromAddress(relayer: relayer))
    }
}