import "BandOracle"

transaction (fee: UFix64) {

    prepare (collector: AuthAccount){
        let feeCollector  <- collector.load<@BandOracle.FeeCollector>(from: BandOracle.FeeCollectorStoragePath) ??
            panic("Cannot load fee collector from maintainer storage")
        feeCollector.setFee(fee: fee)
        collector.save(<- feeCollector, to: BandOracle.FeeCollectorStoragePath)
    }

}