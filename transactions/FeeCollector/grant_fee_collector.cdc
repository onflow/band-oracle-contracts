import "BandOracle"

transaction {

    prepare (oracleAdmin: &Account, collector: &Account){
        
        let adminRef = oracleAdmin.capabilities.borrow<&{BandOracle.OracleAdmin}>(from: BandOracle.OracleAdminStoragePath) ??
            panic("Cannot borrow oracle admin")

        let feeCollector <- adminRef.createNewFeeCollector()
    
        collector.save(<- feeCollector, to: BandOracle.FeeCollectorStoragePath)
    }

}