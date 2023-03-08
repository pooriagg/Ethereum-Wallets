// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/// @title payment splitter contract that user can send multiple ethers in a single transaction
/// @author PooriaGg
contract PaymentSplitter {

    modifier notZeroEther() {
        require(msg.value > 0, "not enough ether.");
        _;
    }

    modifier notZeroLengthAddressArray(address payable [] memory _addrs) {
        require (_addrs.length > 0, "no receiver address found!");
        _;
    }

    fallback() external payable { revert("splitter cannot accept direct sent ether."); }

    receive() external payable { revert("splitter cannot accept direct sent ether."); }

    /// @dev will send specific amount of ether to corresponding target address
    /// @param _addrs traget addresses
    /// @param _amounts amount of ether to be send to each of these addresses 
    function splitV1(
        address payable [] memory _addrs,
        uint[] memory _amounts
    ) external payable notZeroEther notZeroLengthAddressArray(_addrs) { // split to specified amount of ether
        require(_addrs.length == _amounts.length, "addresses and amounts length mismatchh.");

        uint totalEther;
        for (uint i; i < _addrs.length; ++i) {
            _addrs[i].transfer(_amounts[i]);
            totalEther += _amounts[i];
        }
        require(totalEther == msg.value, "Error!");
    }

    /// @dev total ether will equaly tranfered to the entered addresses
    /// @param _addrs traget addresses
    /// note: will send entered ether value equally to all target addresses
    function splitV2(
        address payable [] memory _addrs
    ) external payable notZeroEther notZeroLengthAddressArray(_addrs) { // split to divided amount of ether
        uint share = msg.value / _addrs.length;

        for (uint i; i < _addrs.length; ++i) {
            _addrs[i].transfer(share);
        }
    }

}