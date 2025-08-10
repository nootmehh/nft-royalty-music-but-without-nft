import { Clarinet, Tx, Chain, Account, types } from "clarinet";

Clarinet.test({
  name: "Register a new song and retrieve its metadata",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;

    // Register song
    let block = chain.mineBlock([
      Tx.contractCall(
        "song-registry",
        "register-song",
        [types.ascii("QmExampleCID123456")],
        deployer.address
      ),
    ]);

    block.receipts[0].result.expectOk().expectUint(1n); // first song-id is 1

    // Retrieve metadata
    block = chain.mineBlock([
      Tx.contractCall(
        "song-registry",
        "get-song-metadata",
        [types.uint(1)],
        deployer.address
      ),
    ]);

    block.receipts[0].result.expectSome().expectTuple({
      "metadata-cid": types.ascii("QmExampleCID123456"),
    });
  },
});

Clarinet.test({
  name: "Pay license fee, log playback, and withdraw funds",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const user1 = accounts.get("wallet_1")!;

    // Pay license fee by user1
    let block = chain.mineBlock([
      Tx.contractCall(
        "royalty-manager",
        "pay-license-fee",
        [types.uint(1000)], // pay 1000 microSTX
        user1.address
      ),
    ]);
    block.receipts[0].result.expectOk().expectBool(true);

    // Log playback (only owner can do this)
    block = chain.mineBlock([
      Tx.contractCall(
        "royalty-manager",
        "log-playback",
        [types.uint(1)], // song-id
        deployer.address
      ),
    ]);
    block.receipts[0].result.expectOk().expectBool(true);

    // Withdraw funds to contract owner
    block = chain.mineBlock([
      Tx.contractCall(
        "royalty-manager",
        "withdraw-funds",
        [types.uint(500)], // withdraw 500 microSTX
        deployer.address
      ),
    ]);
    block.receipts[0].result.expectOk().expectBool(true);
  },
});
