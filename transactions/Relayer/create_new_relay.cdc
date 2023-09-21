import BandOracle from "./../../contracts/BandOracle.cdc"

transaction (oracleAdmin: Address) {
    prepare (acct: AuthAccount){
        // Try to claim the published updater capability 
        let updaterCapability = 
            acct.inbox.claim<&{BandOracle.DataUpdater}>(
                BandOracle.getUpdaterCapabilityNameFromAddress (relayer: acct.address),
                provider: oracleAdmin
            )
            ?? panic ("Cannot claim data updater capability")
        // Create a new relayer using the claimed the capability
        // Mind that createRelay is a public function, anyone could call it, but only 
        // an account that has been able to claim a updater capability could execute it successfully
        let relayer <- BandOracle.createRelay(updaterCapability: updaterCapability)
        // Save the new relayer resource into the relayer account
        acct.save(<- relayer, to: BandOracle.RelayStoragePath)
        // Link the relayer resource to a private path for using it latter
        acct.link<&BandOracle.Relay>(BandOracle.RelayPrivatePath, target: BandOracle.RelayStoragePath)
    }
}