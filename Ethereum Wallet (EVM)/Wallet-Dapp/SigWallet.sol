// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.15;

contract SigWallet {
    
    struct BlackList {
        address blocker;
        bytes sig;
        bytes sigData; //  ( return values => to <address>, time <uint32>, amount <uint>, message <string> ) | encoded with abi.encode | decode with abi.decode 
    }
    mapping (address => BlackList) private blockedUsers; // from blocked user to BlackList

    mapping (bytes => bool) private canceledSig;

    mapping (bytes => bool) private signatures; // from sig to isUsed Or Not

    mapping (address => uint) private balances;

    event Deposit(address indexed from, uint amount);
    event Withdraw(address indexed from, address indexed to, uint amount);
    event WithdrawFromWallet(address indexed from, address indexed to, uint amount);
    event WithdrawWithSignature(address indexed signer, address indexed to, uint amount);
    event UserBlocked(address indexed blocker, address indexed blocked, uint time);
    event UserUnBlocked(address indexed blocker, address indexed blocked, uint time);
    event SigCanceled(address indexed signer, bytes indexed signature);

    function balance(address _addr) external view returns(uint256 bal) {
        bal = balances[_addr];
    }

    function deposit() external payable {
        require(blockedUsers[msg.sender].blocker == address(0), "Your Account Is Blocked For Signing Invalid Signature.");
        require(msg.value != 0, "Zero Ether Amount");

        balances[msg.sender] += msg.value; 

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(address _to, uint _amount) external {
        require(blockedUsers[msg.sender].blocker == address(0), "Your Account Is Blocked For Signing Invalid Signature.");
        require(balances[msg.sender] >= _amount, "Insufficient Ether Balance");
        require(_to != address(0), "Address(0)!");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Withdraw(msg.sender, _to, _amount);
    }

    function withdrawFromWallet(address payable _to, uint _amount) external {
        require(blockedUsers[msg.sender].blocker == address(0), "Your Account Is Blocked For Signing Invalid Signature.");
        require(balances[msg.sender] >= _amount, "Insufficient Ether Balance");
        require(_to != address(0), "Address(0)!");

        balances[msg.sender] -= _amount;

        (bool result, ) = _to.call{value: _amount}("");
        require(result, "Error: Failed To Send Ether");

        emit WithdrawFromWallet(msg.sender, _to, _amount);
    }

    function _recover(address _to, uint256 _amount, string calldata _message, bytes memory _sig) internal pure returns(address signer) {
        require(_sig.length == 65, "Invalid Signature Length");

        bytes32 messageHash = keccak256(abi.encodePacked(
            _to,
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

        signer = ecrecover(ethSignedMessage, v, r, s);
    }

    function withdrawWithSig(address _signer, uint256 _amount, string calldata _message, bytes memory _sig) external returns(bool) {
        require(canceledSig[_sig] == false, "Signature Is Canceled By The Signer.");
        require(blockedUsers[msg.sender].blocker == address(0), "Your Account Is Blocked For Signing Invalid Signature.");
        require(signatures[_sig] == false, "Signature Is Used Or Expired");
        require(_sig.length == 65, "Signature Is Invalid");

        address signer = _recover(msg.sender, _amount, _message, _sig);

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

    function freeBlockedUser(address _blocked) external {
        require(_blocked != address(0), "Address(0)");
        require(blockedUsers[_blocked].blocker != address(0), "User Is Not Blocked!");
        require(blockedUsers[_blocked].blocker == msg.sender, "You Are Not The Blocker");

        delete blockedUsers[_blocked];

        emit UserUnBlocked(msg.sender, _blocked, block.timestamp);
    }

    function cancelSig(address _to, uint256 _amount, string calldata _message, bytes memory _sig) external {
        require(msg.sender == _recover(_to, _amount, _message, _sig), "Invalid Signer");
        require(signatures[_sig] == false, "Signature Has Been Used!");

        canceledSig[_sig] = true;

        emit SigCanceled(msg.sender, _sig);
    }

}
