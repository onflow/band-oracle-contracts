import BandOracle from "./../../contracts/BandOracle.cdc"

transaction (oracleAdmin: Address) {
    prepare (acct: AuthAccount){
        let updaterCapability = 
            acct.inbox.claim<&{BandOracle.DataUpdater}>(
                BandOracle.dataUpdaterPrivateBasePath.concat(acct.address.toString()),
                provider: oracleAdmin
            )
            ?? panic ("Cannot claim data updater capability")
        let relayer <- BandOracle.createRelay(updaterCapability: updaterCapability)
        acct.save(<- relayer, to: BandOracle.RelayStoragePath)
        acct.link<&BandOracle.Relay>(BandOracle.RelayPrivatePath, target: BandOracle.RelayStoragePath)
    }
}