web3Provider = null;
rpcUrl = "https://api.avax-test.network/ext/bc/C/rpc";
chainID = 43113;
currentAccount = null;

contracts = {};

// Wallet Contract Data
contracts.Wallet = {};
contracts.Wallet.connect = null;
contracts.Wallet.address = "0x7337f986354157e3e2C48E624670c793224c97cB";
contracts.Wallet.abi = [
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Deposit",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "signer",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "bytes",
				"name": "signature",
				"type": "bytes"
			}
		],
		"name": "SigCanceled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "blocker",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "blocked",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "time",
				"type": "uint256"
			}
		],
		"name": "UserBlocked",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "blocker",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "blocked",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "time",
				"type": "uint256"
			}
		],
		"name": "UserUnBlocked",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Withdraw",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "WithdrawFromWallet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "signer",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "WithdrawWithSignature",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_message",
				"type": "string"
			},
			{
				"internalType": "bytes",
				"name": "_sig",
				"type": "bytes"
			}
		],
		"name": "cancelSig",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "deposit",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_blocked",
				"type": "address"
			}
		],
		"name": "freeBlockedUser",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			}
		],
		"name": "withdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address payable",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			}
		],
		"name": "withdrawFromWallet",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_signer",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_message",
				"type": "string"
			},
			{
				"internalType": "bytes",
				"name": "_sig",
				"type": "bytes"
			}
		],
		"name": "withdrawWithSig",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_addr",
				"type": "address"
			}
		],
		"name": "balance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "bal",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];
///////////////////////////////////////////
contracts.Hash = {};
contracts.Hash.connect = null;
contracts.Hash.address = "0x480f389782008a92f3AAB44bb7897200117E588f";
contracts.Hash.abi = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_msg",
				"type": "string"
			}
		],
		"name": "getHash",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	}
];
/////// START //////////
window.addEventListener("load", async () => {
    const provider = await detectEthereumProvider();
    if (!provider) {
        console.log("Cannot Detect Provider!");
        return false;
    }

    if (typeof web3Provider !== "undefined") {
        web3Provider = provider;
    } else {
        web3Provider = new Web3.providers.HttpProvider(rpcUrl);
    }
    web3 = new Web3(web3Provider);

	web3.eth.handleRevert = true;

    // Connection
    contracts.Wallet.connect = new web3.eth.Contract(contracts.Wallet.abi, contracts.Wallet.address);
    Wallet = contracts.Wallet.connect;

	contracts.Hash.connect = new web3.eth.Contract(contracts.Hash.abi, contracts.Hash.address);
	Hash = contracts.Hash.connect;
	//////////////////////////////////

    // Events /////////////////////////////////////
    const Option = {
        fromBlock: 11644640
    };

    Wallet.events.Deposit(Option)
        .on("data", (e) => {
            console.log(`Deposit:`, e);
        })
    ;
    ////////////////////////////////////////////

    await handleAccount();

    showBalance(); // show user balance in ETH

    ethereum.on("accountsChanged", () => {
        window.location.reload();
    });
	
    ethereum.on("chainChanged", () => {
        window.location.reload();
    });
});
/////////////////////////////////////////////////////////
async function chianValidation() {
    const chain = await ethereum.request({
        method: "eth_chainId"
    });

    const convertedID = parseInt(String(chain), 16);

    return (convertedID == chainID ? true : false);
}
/////////////////////////////////////////////////////////
async function handleAccount() {
    if (typeof window.ethereum !== "undefined" && ethereum.isMetaMask == true) {
        if (await chianValidation()) {
            await ethereum.request({
                method: "eth_requestAccounts"
            }).then((accounts) => {
                if (accounts.length > 0) {
                    currentAccount = accounts[0];

                    console.log(`Current-Account => ${currentAccount}`);

                }else {
                    console.log("Error In Handling Account Request!");
                }
            }).catch((err) => {
                if (err.code == 4001) {
                    console.log("User Rejected Request.");
                }else {
                    console.log(`Error: ${err.message}`);
                }
            });

        } else {
            console.log("Invalid Chain! Please Login To Avax Testnet.");
        }
    } else {
        console.log("Please Install And Login To MetaMask Wallet To Continue.");
    }
}
/////////////////////////////////////////////////////////
async function showBalance() {
    if (typeof window.ethereum !== "undefined" && ethereum.isMetaMask == true) {
        if (await chianValidation()) {

            Wallet.methods.balance(currentAccount).call((err, res) => {

                const bal = web3.utils.fromWei(String(res), "ether");

                if (!err) {
                    console.log(`Balance: ${bal} ETH (${res} Wei)`);
                } else {
                    console.log("Error In Balancing: ", err.message);
                }
            });

        } else {
            console.log("Invalid Chain! Please Login To Avax Testnet.");
        }
    } else {
        console.log("Please Install And Login To MetaMask Wallet To Continue.");
    }
}
/////////////////////////////////////////////////////////
async function deposit() {
	if (typeof window.ethereum !== "undefined" && ethereum.isMetaMask == true) {
        if (await chianValidation()) {

			const amount = document.getElementById("ethD").value;

			if (!isNaN(amount) && amount.length != 0) {

				const toWeiAmount = web3.utils.toWei(String(amount), "ether");

				Wallet.methods.deposit().send({from: currentAccount, value: toWeiAmount}, (err, tx) => {
					if (!err) {
						console.log("Tx Sent Successfully: ", tx);
					} else {
						console.log("Error in sending Tx.");
					}
				});

			} else {
				console.log("Enter Valid Inputs.");
			}

        } else {
            console.log("Invalid Chain! Please Login To Avax Testnet.");
        }
    } else {
        console.log("Please Install And Login To MetaMask Wallet To Continue.");
    }
}
/////////////////////////////////////////////////////////
async function withdraw() {
	if (typeof window.ethereum !== "undefined" && ethereum.isMetaMask == true) {
        if (await chianValidation()) {
			
			const amount = document.getElementById("ethW").value;

			const to = document.getElementById("addrW").value;

			if (!isNaN(amount) && amount.length != 0 && to.length != 0 && web3.utils.isAddress(to)) {

				const toWeiAmount = web3.utils.toWei(String(amount), "ether");

				Wallet.methods.withdrawFromWallet(to, toWeiAmount).send({from: currentAccount}, (err, tx) => {
					if (!err) {
						console.log("Tx Sent Successfully: ", tx);
					} else {
						console.log("Error in sending Tx.");
					}
				});

			} else {
				console.log("Enter Valid Inputs.");
			}

        } else {
            console.log("Invalid Chain! Please Login To Avax Testnet.");
        }
    } else {
        console.log("Please Install And Login To MetaMask Wallet To Continue.");
    }
}
/////////////////////////////////////////////////////////
async function sign() {
	if (typeof window.ethereum !== "undefined" && ethereum.isMetaMask == true) {
        if (await chianValidation()) {
			
			const amount = document.getElementById("amountS").value;

			const to = document.getElementById("toS").value;

			const msg = document.getElementById("msgS").value;

			if (!isNaN(amount) && amount.length != 0 && to.length != 0 && web3.utils.isAddress(to) && msg.length != 0) {

				const toWeiAmount = web3.utils.toWei(String(amount), "ether");

				Hash.methods.getHash(to, toWeiAmount, msg).call(async (err, hash) => {
					if (!err) {

						await ethereum.request({
							method: "personal_sign",
							params: [currentAccount, hash]
						}).then((sig) => {
							console.log("Signature: ", sig);
						}).catch((err) => {
							console.log("Error in signing the message: ", err.message);
						});

					} else {
						console.log("Error in computing the hash.");
					}
				});

			} else {
				console.log("Enter Valid Inputs.");
			}

        } else {
            console.log("Invalid Chain! Please Login To Avax Testnet.");
        }
    } else {
        console.log("Please Install And Login To MetaMask Wallet To Continue.");
    }
}
/////////////////////////////////////////////////////////
async function withdrawWithSig() {
	if (typeof window.ethereum !== "undefined" && ethereum.isMetaMask == true) {
        if (await chianValidation()) {
			
			const amount = document.getElementById("ethSW").value;

			const signer = document.getElementById("signerW").value;

			const msg = document.getElementById("msgW").value;

			const sig = document.getElementById("sigW").value;

			if (!isNaN(amount) && amount.length != 0 && signer.length != 0 && web3.utils.isAddress(signer) && msg.length != 0 && sig.length != 0) {

				const toWeiAmount = web3.utils.toWei(String(amount), "ether");

				Wallet.methods.withdrawWithSig(signer, toWeiAmount, msg, sig).send({from: currentAccount}, (err, tx) => {
					if (!err) {
						console.log("Tx Sent Successfully: ", tx);
					} else {
						console.log("Error in sending Tx.");
					} 
				});

			} else {
				console.log("Enter Valid Inputs.");
			}

        } else {
            console.log("Invalid Chain! Please Login To Avax Testnet.");
        }
    } else {
        console.log("Please Install And Login To MetaMask Wallet To Continue.");
    }
}
/////////////////////////////////////////////////////////
async function cancelSignature() {
	if (typeof window.ethereum !== "undefined" && ethereum.isMetaMask == true) {
        if (await chianValidation()) {
			
			const amount = document.getElementById("amountSC").value;

			const to = document.getElementById("toSC").value;

			const msg = document.getElementById("msgSC").value;

			const sig = document.getElementById("sigSC").value;

			if (!isNaN(amount) && amount.length != 0 && to.length != 0 && web3.utils.isAddress(to) && msg.length != 0 && sig.length != 0) {

				const toWeiAmount = web3.utils.toWei(String(amount), "ether");

				Wallet.methods.cancelSig(to, toWeiAmount, msg, sig).send({from: currentAccount}, (err, tx) => {
					if (!err) {
						console.log("Tx Sent Successfully: ", tx);
					} else {
						console.log("Error in sending Tx.");
					} 
				});

			} else {
				console.log("Enter Valid Inputs.");
			}

        } else {
            console.log("Invalid Chain! Please Login To Avax Testnet.");
        }
    } else {
        console.log("Please Install And Login To MetaMask Wallet To Continue.");
    }
}