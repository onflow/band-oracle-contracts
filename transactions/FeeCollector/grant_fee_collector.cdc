import "BandOracle"

transaction {

    prepare (oracleAdmin: auth(BorrowValue)&Account, collector: auth(SaveValue)&Account){
        
        let adminRef = oracleAdmin.storage.borrow<&{BandOracle.OracleAdmin}>(from: BandOracle.OracleAdminStoragePath) ??
            panic("Cannot borrow oracle admin")

        let feeCollector <- adminRef.createNewFeeCollector()
    
        collector.storage.save(<- feeCollector, to: BandOracle.FeeCollectorStoragePath)
    }

}