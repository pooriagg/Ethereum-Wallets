// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

/// @title ethereum signature based wallet
/// @author PooriaGg
contract SigWallet {
    
    struct BlackList {
        address blocker;
        bytes sig;
        bytes sigData; //  ( return values => to <address>, time <uint32>, amount <uint>, message <string> ) | encoded with abi.encode | decode with abi.decode 
    }
    mapping (address => BlackList) public blockedUsers; // from blocked user to BlackList

    mapping (bytes => bool) public signatures; // from sig to isUsed Or Not

    mapping (address => uint) public balances;

    event Deposit(address indexed from, uint amount);
    event Withdraw(address indexed from, address indexed to, uint amount);
    event WithdrawFromWallet(address indexed from, address indexed to, uint amount);
    event WithdrawWithSignature(address indexed signer, address indexed to, uint amount);
    event UserBlocked(address indexed blocker, address indexed blocked, uint time);
    event UserUnBlocked(address indexed blocker, address indexed blocked, uint time);

    /// @dev user can deposit non-zero amount of ether to this wallet via this function
    /// note: users that are blocked can not deposit any fund to this contract
    function deposit() external payable {
        require(blockedUsers[msg.sender].blocker == address(0), "Your Account Is Blocked For Signing Invalid Signature.");
        require(msg.value != 0, "Zero Ether Amount");

        balances[msg.sender] += msg.value; 

        emit Deposit(msg.sender, msg.value);
    }

    /// @dev user can send ether to other internal wallet that wishes
    /// note: this method of withdraw is an internal method that only updates the 'balance' mapping
    /// @param _to address of recepient (non-zero address)
    /// @param _amount amount of ether that will transfer to the recepient balance
    function withdraw(address _to, uint _amount) external {
        require(blockedUsers[msg.sender].blocker == address(0), "Your Account Is Blocked For Signing Invalid Signature.");
        require(balances[msg.sender] >= _amount, "Insufficient Ether Balance");
        require(_to != address(0), "Address(0)!");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Withdraw(msg.sender, _to, _amount);
    }

    /// @dev user can send ether to other externaly wallet that wishes
    /// note: this method of withdraw is an external method that after updating the 'balance' mapping it will send ether to the recepient
    /// @param _to address of recepient (non-zero address)
    /// @param _amount amount of ether that will transfer to the recepient wallet 
    function withdrawFromWallet(address payable _to, uint _amount) external {
        require(blockedUsers[msg.sender].blocker == address(0), "Your Account Is Blocked For Signing Invalid Signature.");
        require(balances[msg.sender] >= _amount, "Insufficient Ether Balance");
        require(_to != address(0), "Address(0)!");

        balances[msg.sender] -= _amount;

        (bool result, ) = _to.call{value: _amount}("");
        require(result, "Error: Failed To Send Ether");

        emit WithdrawFromWallet(msg.sender, _to, _amount);
    }

    /// @dev via using this function user can withdraw a specific amount of ether from the signer to his internal wallet
    /// note: the signature must be valid
    /// note: if the signer of the signature doesn't have enough balance he will be blocked from this contract 
    /// until the person who received this invalid sign unblockes him/her;
    /// @param _signer signer of the permissinon
    /// @param _amount amount of ether that signer give permission
    /// @param _message a message written by the signer
    /// @param _sig the signature that signer must give it to the user who wants to use this function
    function withdrawWithSig(
            address _signer,
            uint _amount,
            string calldata _message,
            bytes memory _sig
        ) external returns(bool) {
        require(blockedUsers[msg.sender].blocker == address(0), "Your Account Is Blocked For Signing Invalid Signature.");
        require(signatures[_sig] == false, "Signature Is Used Or Expired");
        require(_sig.length == 65, "Signature Is Invalid");

        bytes32 messageHash = keccak256(abi.encodePacked(
            msg.sender,
            _amount,
            _message
        ));

        bytes32 ethSignedMessage = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));

        bytes32 r; // 32 bytes
        bytes32 s; // 32 bytes
        uint8 v; // 1 byte

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        address signer = ecrecover(ethSignedMessage, v, r, s);

        require(signer == _signer, "Invalid Signature Params");

        if (balances[_signer] < _amount) {
            blockedUsers[_signer] = BlackList({
                blocker: msg.sender,
                sig: _sig,
                sigData: abi.encode(
                    msg.sender,
                    _amount,
                    _message
                )
            });
            
            emit UserBlocked(msg.sender, _signer, block.timestamp);

            signatures[_sig] = true;

            return false;
        }

        balances[_signer] -= _amount;
        balances[msg.sender] += _amount;

        signatures[_sig] = true;

        emit WithdrawWithSignature(_signer, msg.sender, _amount);

        return true;
    }

    /// @dev the person who used the invalid signature only can free the signer account of this invalid signuture
    /// @param _blocked the signer address
    /// note: the address must be a non-zero address
    function freeBlockedUser(address _blocked) external {
        require(_blocked != address(0), "Address(0)");
        require(blockedUsers[_blocked].blocker != address(0), "User Is Not Blocked!");
        require(blockedUsers[_blocked].blocker == msg.sender, "You Are Not The Blocker");

        delete blockedUsers[_blocked];

        emit UserUnBlocked(msg.sender, _blocked, block.timestamp);
    }

}