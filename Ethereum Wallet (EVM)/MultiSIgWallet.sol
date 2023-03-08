//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract MultiSigWallet {

    address public immutable owner;
    uint8 public immutable required;

    mapping(address => bool) private coOwners;

    struct Tx {
        uint amount;
        address to;
        bool executed;
    }
    Tx[] public txs;

    mapping(uint => mapping(address => bool)) private sig;
    mapping(uint => uint) private totalSigs;

    event NewTxCreated(uint indexed txId, address indexed creator, uint time);
    event TxExecuted(uint indexed txId, address indexed to, uint time);

    constructor(uint8 _num) payable {
        owner = msg.sender;
        required = _num;
    }

    receive() external payable {}

    modifier onlyOnwer() {
        require(msg.sender == owner, "Only Owner");
        _;
    }

    modifier ownerAndCoOwnersOnly() {
        require(msg.sender == owner || coOwners[msg.sender] == true, "Nethier Owner Nor CoOwner");
        _;
    }

    /// @dev owner of the contract can add arbitrary amount of admins
    /// @param _add the address of the new admin
    function addCoOwner(address _add) external onlyOnwer {
        require(_add != address(0), "Invalid Address");
        require(coOwners[_add] == false, "User Already Signed");

        coOwners[_add] = true;
    }

    /// @dev the owner and all admins can create a new transaction by using this function
    /// @param _amount amount of ether
    /// @param _to the recepient address
    function createNewTx(uint _amount, address _to) external ownerAndCoOwnersOnly {
        uint size;
        assembly {
            size := extcodesize(_to)
        }
        require(size == 0, "Address Cannot Be A Contract!");

        Tx memory newTx = Tx({amount: _amount, to: _to, executed: false});

        txs.push(newTx);

        emit NewTxCreated(txs.length - 1, msg.sender, block.timestamp);
    }

    /// @dev the owner and all admins can sign a valid tx if they wish
    /// @param _txId the id of the tx
    /// note tx must be valid and not executed before
    function signTx(uint _txId) external ownerAndCoOwnersOnly {
        Tx memory txData = txs[_txId];

        require(_txId < txs.length, "Invalid Tx id");
        require(txData.executed == false, "Tx Already Executed");
        require(sig[_txId][msg.sender] != true, "Already Signed");

        sig[_txId][msg.sender] = true;
        totalSigs[_txId] += 1;
    }

    /// @dev the owner and all admins can unsign a signed tx
    /// @param _txId the id of the tx
    /// note tx must be valid and not executed yet
    function unsignTx(uint _txId) external ownerAndCoOwnersOnly {
        Tx memory txData = txs[_txId];

        require(_txId < txs.length, "Invalid Tx id");
        require(txData.executed == false, "Tx Already Executed");
        require(sig[_txId][msg.sender] != false, "Already unSigned");

        sig[_txId][msg.sender] = false;
        totalSigs[_txId] -= 1;
    }

    /// @dev the owner and all admins can execute a valid tx
    /// @param _txId the id of the tx
    /// note tx must be have sufficient amount of signs and not executed 
    function executeTx(uint _txId) external ownerAndCoOwnersOnly {
        Tx storage txData = txs[_txId];

        require(_txId < txs.length, "Invalid Tx id");
        require(txData.executed == false, "Tx Already Executed");
        require(totalSigs[_txId] >= required, "Insufficent Tx Signs");

        txData.executed = true;

        (bool result, ) = payable(txData.to).call{value: txData.amount}("");

        require(result == true, "Something Went Wrong");

        emit TxExecuted(_txId, txData.to, block.timestamp);
    }

}
