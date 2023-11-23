import "BandOracle"

transaction {

    prepare (oracleAdmin: AuthAccount, collector: AuthAccount){
        
        let adminRef = oracleAdmin.borrow<&{BandOracle.OracleAdmin}>(from: BandOracle.OracleAdminStoragePath) ??
            panic("Cannot borrow oracle admin")

        let feeCollector <- adminRef.createNewFeeCollector()
    
        collector.save(<- feeCollector, to: BandOracle.FeeCollectorStoragePath)
    }

}