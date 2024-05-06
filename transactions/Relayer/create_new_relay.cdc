import "BandOracle"

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
        let relayPrivatePathCap = acct.capabilities.storage.issue<&BandOracle.Relay>(BandOracle.RelayPrivatePath)
        acct.capabilities.publish(relayPrivatePathCap, at: BandOracle.RelayStoragePath)
    }
}