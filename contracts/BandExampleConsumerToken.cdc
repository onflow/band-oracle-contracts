import "FungibleToken"
import "FlowToken"
import "BandOracle"

/**
Example contract to illustrate how to use the Band Protocol Oracle.

This contract represents a FungibleToken, a requested amount of which can be minted 
by anyone based on payment provided in a FLOW token vault. The price of 
`BandExampleConsumerToken` is fixed by the admin in USD. The price set is then used 
to enforce a minimum and calculate the number of `BandExampleConsumerToken`s which can be swapped for 
the amount of FLOW provided.

This example contract showcases a function enabling the exchange of Flow tokens for 
`BandExampleConsumerTokens`. When the swap function is invoked, the contract 
leverages the most recently stored FLOW/USD price quote for the token swap. 

It should be noted that this contract example is not representative of how oracle integration
would generally be implemented. The example highlights a use-case typically handled by 
Decentralized Exchanges (DEXs) which use oracle price quotes to perform token swaps. 
Unless you are operating an exchange, or otherwise exposing price quotes obtained to 
callers of your contract, other use-cases may only need to query current price quotes using 
a transaction.

We recommend that dapps maintain up to date price quotes by listening for the `BandOracleSymbolsUpdated` 
event emitted by the BandOracle contract. When a symbol used by the dapp has it's price updated, a 
transaction should be run to update price quotes within the contract. In the current example calling the
`updateTokenFlowPrice()` method from the admin resource achieves this.
**/
access(all) contract BandExampleConsumerToken: FungibleToken {

    // The USD price is determined by the admin, then the equivalent Flow price is 
    // calculated by getting the FLOW/USD rate from the band oracle
    access(all) var tokenUSDPrice: UFix64
    access(all) var tokenFlowPrice: UFix64
    
    // The funds collecting minting tokens will be stored here. This vault will be 
    // also used to pay for the oracle fees.
    access(all) let flowTreasure: @FungibleToken.Vault

    // Total supply of tokens in existence
    access(all) var totalSupply: UFix64

    // Paths
    access(all) let VaultStoragePath: StoragePath
    access(all) let ReceiverPublicPath: PublicPath
    access(all) let BalancePublicPath: PublicPath

    // Event that is emitted when the contract is created
    access(all) event TokensInitialized(initialSupply: UFix64)

    // Event that is emitted when tokens are withdrawn from a Vault
    access(all) event TokensWithdrawn(amount: UFix64, from: Address?)

    // Event that is emitted when tokens are deposited to a Vault
    access(all) event TokensDeposited(amount: UFix64, to: Address?)

    // Event that is emitted when new tokens are minted
    access(all) event TokensMinted(amount: UFix64)

    // Event that is emitted when tokens are destroyed
    access(all) event TokensBurned(amount: UFix64)

    // Event that is emitted when a new minter resource is created
    access(all) event MinterCreated()

    // Event that is emitted when a new burner resource is created
    access(all) event BurnerCreated()

    // Vault
    //
    // Each user stores an instance of only the Vault in their storage
    // The functions in the Vault and governed by the pre and post conditions
    // in FungibleToken when they are called.
    // The checks happen at runtime whenever a function is called.
    //
    // Resources can only be created in the context of the contract that they
    // are defined in, so there is no way for a malicious user to create Vaults
    // out of thin air. A special Minter resource needs to be defined to mint
    // new tokens.
    //
    access(all) resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {

        // holds the balance of a users tokens
        access(all) var balance: UFix64

        // initialize the balance at resource creation time
        init(balance: UFix64) {
            self.balance = balance
        }

        // withdraw
        //
        // Function that takes an integer amount as an argument
        // and withdraws that amount from the Vault.
        // It creates a new temporary Vault that is used to hold
        // the money that is being transferred. It returns the newly
        // created Vault to the context that called so it can be deposited
        // elsewhere.
        //
        access(all) fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        // deposit
        //
        // Function that takes a Vault object as an argument and adds
        // its balance to the balance of the owners Vault.
        // It is allowed to destroy the sent Vault because the Vault
        // was a temporary holder of the tokens. The Vault's balance has
        // been consumed and therefore can be destroyed.
        access(all) fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as @BandExampleConsumerToken.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault

            if self.balance > 0.0 {
                BandExampleConsumerToken.totalSupply = BandExampleConsumerToken.totalSupply - self.balance
            }
        }
    }

    // createEmptyVault
    //
    // Function that creates a new Vault with a balance of zero
    // and returns it to the calling context. A user must call this function
    // and store the returned Vault in their storage in order to allow their
    // account to be able to receive deposits of this token type.
    //
    access(all) fun createEmptyVault(): @FungibleToken.Vault {
        return <-create Vault(balance: 0.0)
    }

    // Admin resource that allows to set the token price
    access(all) resource Administrator {
        
        access(all) fun setNewTokensUSDPrice (price: UFix64) {
            BandExampleConsumerToken.tokenUSDPrice = price
            BandExampleConsumerToken.updateTokenFlowPrice()
        }

        access(all) fun updateTokenFlowPrice () {
            BandExampleConsumerToken.updateTokenFlowPrice()
        }

    }

    // Private contract function that calls the `BandOracle.getReferenceData` method
    // for updating the `tokenFlowPrice` field.
    access(contract) fun updateTokenFlowPrice() {
        let payment <- self.flowTreasure.withdraw(amount: BandOracle.getFee())
        let usdFlowData = BandOracle.getReferenceData (baseSymbol: "USD", quoteSymbol: "FLOW", payment: <- payment)
        self.tokenFlowPrice = self.tokenUSDPrice * usdFlowData.fixedPointRate
    }

    // Public function that allows anyone to mint themselves a bunch of tokens, in
    // exchange of the needed amount of Flow tokens.
    access(all) fun swapTokens(maxPrice: UFix64, payment: @FungibleToken.Vault): @BandExampleConsumerToken.Vault {
        pre {
            self.tokenFlowPrice < maxPrice: "Current token price is higher than the maximum desired price,"
        }
        let vault <- payment as @BandExampleConsumerToken.Vault
        let amount = vault.balance / self.tokenFlowPrice
        self.flowTreasure.deposit(from: <-vault)
        self.totalSupply = self.totalSupply + amount
        emit TokensMinted(amount: amount)
        return <- create Vault(balance: amount)
    }

    init() {
        // Set-up all contract level fields
        self.totalSupply = 0.0
        self.tokenUSDPrice = 0.0
        self.tokenFlowPrice = 0.0
        self.VaultStoragePath = /storage/BandExampleConsumerToken
        self.ReceiverPublicPath = /public/BandExampleConsumerTokenReceiver
        self.BalancePublicPath = /public/BandExampleConsumerTokenBalance

        // This vault will need to be funded for allowing the contract to pay for the 
        // band oracle rate updates.
        self.flowTreasure <- FlowToken.createEmptyVault()

        let admin <- create Administrator()
        self.account.save(<-admin, to: /storage/flowTokenAdmin)

        // Emit an event that shows that the contract was initialized
        emit TokensInitialized(initialSupply: self.totalSupply)
    }
}