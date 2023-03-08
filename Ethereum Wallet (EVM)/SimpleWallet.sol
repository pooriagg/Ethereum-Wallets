// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/// @title a simple ether wallet
/// @author PooriaGg
contract SimpleWallet {

    mapping (address => uint) public balances;

    event Deposit(address indexed from, uint amount);
    event Withdraw(address indexed from, address indexed to, uint amount);
    event WithdrawFromWallet(address indexed from, address indexed to, uint amount);

    /// @notice deposit ether to this wallet via this function
    /// @dev after depositing some ether to this contract the Deposit event will emite
    /// Note: must deposit ether with higher amount than zero
    function deposit() external payable {
        require(msg.value != 0, "Zero Ether Amount");

        balances[msg.sender] += msg.value; 

        emit Deposit(msg.sender, msg.value);
    }

    /// @notice withdraw ether from the wallet (internally)
    /// @dev it will increase the balance of the recepient internally after that the Withdraw event will emit
    /// Note: user must have sufficient balance to send specific amount of ether
    /// @param _to address of the recepient that must be not equal to zero
    /// @param _amount amount of ether that usr wishes to send
    function withdraw(address _to, uint _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient Ether Balance");
        require(_to != address(0), "Address(0)!");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Withdraw(msg.sender, _to, _amount);
    }

    /// @notice withdraw ether from the wallet (externally) 
    /// @dev it will increase the balance of the recepient externally so that recepient can see it in his/her Metamask wallet after that 
    /// the WithdrawFromWallet event will emit
    /// Note: user must have sufficient balance to send specific amount of ether
    /// @param _to address of the recepient that must be not equal to zero
    /// @param _amount amount of ether that usr wishes to send
    function withdrowFromWallet(address payable _to, uint _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient Ether Balance");
        require(_to != address(0), "Address(0)!");

        balances[msg.sender] -= _amount;

        (bool result, ) = _to.call{value: _amount}("");
        require(result, "Error: Failed To Send Ether");

        emit WithdrawFromWallet(msg.sender, _to, _amount);
    }

}
