import "BandOracle"

transaction (fee: UFix64) {
    let feeCollector: &BandOracle.FeeCollector

    prepare (collector: AuthAccount){
        self.feeCollector = collector.borrow<&BandOracle.FeeCollector>(from: BandOracle.FeeCollectorStoragePath)
            ?? panic("Cannot load fee collector from maintainer storage")
    }
    execute {
        self.feeCollector.setFee(fee: fee)
    }
    
    post {
        BandOracle.getFee() == fee: "Fee was not set correctly"
    }
}