const MultiSigWallet = artifacts.require("MultiSigWallet");

contract("MultiSigWallet", (accounts) => {
    const REQUIRED_CONFIRAMTIONS = 2;

    let multiSigWallet;
    beforeEach(async () => {
        multiSigWallet = await MultiSigWallet.new(REQUIRED_CONFIRAMTIONS);
    });

    describe("Checking restricted methods and adding new coowners", () => {
        it("Should reject the none-owner user", async () => {
            try {
                const newCoOwner = accounts[1];
                await multiSigWallet.addCoOwner(newCoOwner, { from : accounts[2] });
                assert(false);
            } catch {
                assert(true);
            }
        });

        it("Should owner connot add a duplicated coowner", async () => {
            await multiSigWallet.addCoOwner(accounts[1], { from : accounts[0] });
            await multiSigWallet.addCoOwner(accounts[2], { from : accounts[0] });
            await multiSigWallet.addCoOwner(accounts[3], { from : accounts[0] });

            try {
                const newCoOwner = accounts[1];
                await multiSigWallet.addCoOwner(newCoOwner, { from : accounts[0] });
                assert(false);
            } catch {
                assert(true);
            }
        });
    });

    describe("Creating a transaction", () => {   
        beforeEach(async () => {
            await multiSigWallet.addCoOwner(accounts[1], { from : accounts[0] });
            await multiSigWallet.addCoOwner(accounts[2], { from : accounts[0] });
            await multiSigWallet.addCoOwner(accounts[3], { from : accounts[0] });
        });

        it("Should not create new tx by a none-owner/coowner user", async () => {
            try {
                const to = accounts[7];
                const value = 1000000000000000000;
                await multiSigWallet.createNewTx(value.toString(), to, { from : accounts[5] });
                assert(false);
            } catch {
                assert(true);
            }
        });

        it("Should add new tx to txs array and emit an event", async () => {
            var tx;

            try {
                const to = accounts[8];
                const value = 1000000000000000000;
                tx = await multiSigWallet.createNewTx(value.toString(), to, { from : accounts[1] });
            } catch {
                assert(false);
                return false;
            }

            const { logs } = tx;

            assert.equal(logs[0].event, "NewTxCreated");
            assert.equal(logs[0].args.txId, 0);
            assert.equal(logs[0].args.creator, accounts[1]);

            const txData = await multiSigWallet.txs(0);
            assert.equal(txData[0], "1000000000000000000");
            assert.equal(txData[1], accounts[8]);
            assert.equal(txData[2], false);
        });
    });

    describe("Signing, unsigning and executing a transaction", () => {
        it("Should none-owner/coowner, cannot sign a tx", async () => {
            try {
                const txId = 10; // not exist tx
                await multiSigWallet.signTx(txId, { from : accounts[0] });
            } catch {
                assert(true);
                return false;
            }

            assert(false);
        });

        it("Should sign and execute a tx", async () => {
            await multiSigWallet.addCoOwner(accounts[1], { from : accounts[0] });
            await multiSigWallet.addCoOwner(accounts[2], { from : accounts[0] });
            await multiSigWallet.addCoOwner(accounts[3], { from : accounts[0] });

            try {
                // create a new tx
                const to = accounts[8];
                const value = 0;
                await multiSigWallet.createNewTx(value.toString(), to, { from : accounts[3] });
                // sign the tx with at least 2 of valid people
                const txId = 0;
                await multiSigWallet.signTx(txId, { from : accounts[0] });
                await multiSigWallet.signTx(txId, { from : accounts[2] });
                // execute the tx
                const txData = await multiSigWallet.executeTx(txId, { from : accounts[3] });
                const { logs } = txData;
                assert.equal(logs[0].event, "TxExecuted");
                assert.equal(logs[0].args.txId, 0);
                assert.equal(logs[0].args.to, to);
            } catch {
                assert(false);
            }
        });

        it("Should cannot execute a tx with lower signed signatures", async () => {
            try {
                // create a new tx
                const to = accounts[8];
                const value = 0;
                await multiSigWallet.createNewTx(value.toString(), to, { from : accounts[0] });
                // sign once the tx
                const txId = 0;
                await multiSigWallet.signTx(txId, { from : accounts[0] });
                // execute the tx
                await multiSigWallet.executeTx(txId, { from : accounts[0] });
            } catch {
                assert(true);
                return true;
            }

            assert(false);
        });

        it("Should owner/coowner cannot sign a tx twice", async () => {
            try {
                // create a new tx
                const to = accounts[8];
                const value = 0;
                await multiSigWallet.createNewTx(value.toString(), to, { from : accounts[0] });
                // sign once the tx
                const txId = 0;
                await multiSigWallet.signTx(txId, { from : accounts[0] });
                await multiSigWallet.signTx(txId, { from : accounts[0] });
            } catch {
                assert(true);
                return true;
            }

            assert(false);
        });

        it("Should cannot unsign a tx that didn't signed before", async () => {
            try {
                // create a new tx
                const to = accounts[8];
                const value = 0;
                await multiSigWallet.createNewTx(value.toString(), to, { from : accounts[0] });
                // sign once the tx
                await multiSigWallet.unsignTx(0, { from : accounts[0] });
            } catch {
                assert(true);
                return true;
            }

            assert(false);
        });

        it("Should cannot sign a tx that does not exist", async () => {
            try {
                await multiSigWallet.signTx(5, { from : accounts[0] });
            } catch {
                assert(true);
                return true;
            }

            assert(false);
        });
    });
});