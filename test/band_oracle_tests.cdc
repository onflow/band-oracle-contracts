import Test
import BlockchainHelpers
import "BandOracle"
import "FlowToken"

pub let admin = Test.getAccount(0x000000000000006)
pub let maintainer = Test.createAccount()
pub let relayer = Test.createAccount()
pub let consumer = Test.createAccount()

pub fun setup () {
    let err1 = Test.deployContract(
        name: "BandOracle",
        path: "../contracts/BandOracle.cdc",
        arguments: []
    )
    Test.expect(err1, Test.beNil())
}

pub fun beforeEach () {

}

pub fun afterEach () {

}

pub fun testSetUpRelayer () {
    let txResult1 = executeTransaction(
        "../transactions/OracleAdmin/link_and_publish_data_updater_capability.cdc",
        [relayer.address],
        admin
    )
    Test.expect(txResult1, Test.beSucceeded())

    let txResult2 = executeTransaction(
        "../transactions/Relayer/create_new_relay.cdc",
        [admin.address],
        relayer
    )
    Test.expect(txResult2, Test.beSucceeded())
}

pub fun testSetUpFeeCollector () {
    let code = Test.readFile("../transactions/FeeCollector/grant_fee_collector.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [admin.address, maintainer.address],
        signers: [admin, maintainer],
        arguments: []
    )
    let txResult = Test.executeTransaction(tx)
    Test.expect(txResult, Test.beSucceeded())
}

pub fun testRelayQuotes () {
    let txResult = executeTransaction(
        "../transactions/Relayer/relay_rates.cdc",
        [{"BTC": 34_567_890_123_456 as UInt64, "FLOW":567_890_123 as UInt64}, 0 as UInt64, 0 as UInt64],
        relayer
    )
    Test.expect(txResult, Test.beSucceeded())

    let symbolsUpdatedEvents = Test.eventsOfType(Type<BandOracle.BandOracleSymbolsUpdated>())
    Test.assertEqual(1, symbolsUpdatedEvents.length)
}

pub fun testRelayUpdatedQuotes () {
    let txResult = executeTransaction(
        "../transactions/Relayer/relay_rates.cdc",
        [{"BTC": 67_890_123_456_789 as UInt64, "FLOW":1_567_890_123 as UInt64}, 1000 as UInt64, 1 as UInt64],
        relayer
    )
    Test.expect(txResult, Test.beSucceeded())

    let symbolsUpdatedEvents = Test.eventsOfType(Type<BandOracle.BandOracleSymbolsUpdated>())
    let event = symbolsUpdatedEvents[1] as! BandOracle.BandOracleSymbolsUpdated
    log(event)
    Test.assertEqual(["BTC","FLOW"], event.symbols)
    Test.assertEqual(1 as UInt64, event.requestID)
}

pub fun testRelayOlderUpdatedQuotes () {
    let txResult = executeTransaction(
        "../transactions/Relayer/relay_rates.cdc",
        [{"BTC": 34_567_890_123_456 as UInt64, "FLOW":567_890_123 as UInt64}, 500 as UInt64, 2 as UInt64],
        relayer
    )
    Test.expect(txResult, Test.beSucceeded())

    let symbolsUpdatedEvents = Test.eventsOfType(Type<BandOracle.BandOracleSymbolsUpdated>())
    let event = symbolsUpdatedEvents[2] as! BandOracle.BandOracleSymbolsUpdated
    log(event)
    Test.assertEqual([] as [String], event.symbols)
    Test.assertEqual(2 as UInt64, event.requestID)
}

pub fun testForceRelayQuotes () {
    let txResult = executeTransaction(
        "../transactions/Relayer/force_relay_rates.cdc",
        [{"BTC": 44_567_890_123_456 as UInt64, "FLOW":467_890_123 as UInt64}, 999 as UInt64, 3 as UInt64],
        relayer
    )
    Test.expect(txResult, Test.beSucceeded())

    let symbolsUpdatedEvents = Test.eventsOfType(Type<BandOracle.BandOracleSymbolsUpdated>())
    let event = symbolsUpdatedEvents[3] as! BandOracle.BandOracleSymbolsUpdated
    Test.assertEqual(["BTC","FLOW"], event.symbols)
    Test.assertEqual(3 as UInt64, event.requestID)
}

pub fun testSetFee () {
    let txResult = executeTransaction(
        "../transactions/FeeCollector/set_fee.cdc",
        [1.0],
        maintainer
    )
    Test.expect(txResult, Test.beSucceeded())
}

pub fun testGetRates () {
    mintFlow(to: consumer, amount: 1500.0)
    let txResult = executeTransaction (
        "../transactions/Consumer/get_rates.cdc",
        ["BTC", "FLOW"],
        consumer
    )
    Test.expect(txResult, Test.beSucceeded())
}

pub fun tearDown () {

}