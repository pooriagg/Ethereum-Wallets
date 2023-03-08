// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Locker {

    address private immutable owner;

    uint private constant MIN_DELAY = 5 days;
    uint private constant MAX_DELAY = 30 days;

    struct Tx {
        uint creationTime;
        address creator;
        bytes data; //  1) to  2) amount
        bool isExecuted;
        bool isCanceled;
    }
    uint totalTxCount = 1;

    event TxCreated(uint indexed creationTime, address indexed creator, uint indexed txId);
    event TxExecuted(uint indexed amount, address indexed executer, uint indexed txId);
    event TxCanceled(address indexed admin, address indexed creator, uint indexed txId);
    event Admin(address indexed admin, bool isApproved, uint time);
    event Deposited(address indexed depositor, uint indexed amount, uint indexed time);

    mapping (address => bool) private admins;
    mapping (address => int) private balance;
    mapping (uint => Tx) private transaction;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        require(msg.value > 0 wei, "insufficient Ether Amount.");

        balance[msg.sender] += int(msg.value);

        emit Deposited({
            depositor: msg.sender,
            amount: msg.value,
            time: block.timestamp
        });
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner Can Access Sir!");
        _;
    }

    function createNewTx(address _to, uint _amount) external returns(uint index) {
        require(_to != address(0) && _amount != 0, "Invalid Data Inserted.");
        require(_amount <= address(this).balance, "Insufficient Contract Balance.");

        Tx memory newTx = Tx({
            creationTime: block.timestamp,
            creator: msg.sender,
            data: abi.encode(_to, _amount),
            isExecuted: false,
            isCanceled: false
        });

        transaction[totalTxCount] = newTx;
        totalTxCount += 1;

        emit TxCreated({
            creationTime: block.timestamp,
            creator: msg.sender,
            txId: totalTxCount - 1
        });

        index = totalTxCount - 1;
    }

    function executeTx(uint _txId) external {
        Tx storage txData = transaction[_txId];
        require(txData.creator == msg.sender, "Only Tx Creator Can Execute It.");
        require(txData.isCanceled == false && txData.isExecuted == false, "Cannot Execute This Tx.");
        require
        (
            block.timestamp > txData.creationTime + MIN_DELAY &&
            block.timestamp < txData.creationTime + MAX_DELAY, 
            "Tx Execution Time Expired Or Should Wait Until The Min Delay Time."
        );

        (address to, uint amount) = abi.decode(txData.data, (address, uint));

        txData.isExecuted = true;

        balance[txData.creator] -= int(amount);

        (bool result, ) = to.call{value: amount}("");
        require(result == true, "Something Went Wrong.");

        emit TxExecuted({
            amount: amount,
            executer: msg.sender,
            txId: _txId
        });
    }

    function cancelTx(uint _txId) external {
        Tx storage txData = transaction[_txId];
        require(txData.creator != address(0), "Invalid Tx Id!");
        require(msg.sender == txData.creator || msg.sender == owner || admins[msg.sender] == true, "Invalid Access.");
        require(txData.isCanceled == false && txData.isExecuted == false, "Cannot Cancel Tx.");

        txData.isCanceled = true;

        emit TxCanceled({
            admin: msg.sender,
            creator: txData.creator,
            txId: _txId
        });
    }

    function deposit() external payable {
        require(msg.value > 0 wei, "insufficient Ether Amount.");

        balance[msg.sender] += int(msg.value);

        emit Deposited({
            depositor: msg.sender,
            amount: msg.value,
            time: block.timestamp
        }); 
    }

    function admin(address _admin, bool _isApproved) external onlyOwner {
        require(_admin != address(0), "invalid Address. (address zero!)");
        
        admins[_admin] = _isApproved;

        emit Admin({
            admin: _admin,
            isApproved: _isApproved,
            time: block.timestamp
        });
    }

    function txData(uint _txId) external view returns(Tx memory) {
        return transaction[_txId];
    }

    function total() external view returns(uint totalTxs) {
        totalTxs = totalTxCount - 1;
    }

}
