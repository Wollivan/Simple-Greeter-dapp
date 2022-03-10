// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

contract MultiSig {
    address[] public owners;
    uint public transactionCount;
    uint public required;

    struct Transaction {
        address payable destination;
        uint value;
        bool executed;
        bytes data;
    }

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;

    receive() payable external {}

    function executeTransaction(uint _txId) public {
        require(isConfirmed(_txId));
        // get the transaction object
        Transaction storage _tx = transactions[_txId];
        // transfer the value to the destination
        (bool success, ) = _tx.destination.call{ value: _tx.value }(_tx.data);
        require(success, "Failed to execute transaction");
        // mark as exectuted (imagine if you didn't?!?!?
        _tx.executed = true;    
    }


    function isConfirmed(uint _txId) public view returns(bool) {
        return getConfirmationsCount(_txId) >= required;
    }

    function getConfirmationsCount(uint transactionId) public view returns(uint) {
        uint count;
        for(uint i = 0; i < owners.length; i++) {
            if(confirmations[transactionId][owners[i]]) {
                count++;
            }
        }
        return count;
    }

    function isOwner(address addr) private view returns(bool) {
        for(uint i = 0; i < owners.length; i++) {
            if(owners[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function submitTransaction(address payable dest, uint value, bytes memory data) public {
        uint id = addTransaction(dest, value, data);
        confirmTransaction(id);
    }

    function confirmTransaction(uint transactionId) public {
        require(isOwner(msg.sender));
        confirmations[transactionId][msg.sender] = true;
        
        // execute if there are enough signatures
        if(getConfirmationsCount(transactionId) >= required) {
            executeTransaction(transactionId);
        }
    }

    function addTransaction(address payable destination, uint value, bytes memory data) internal returns(uint) {
        transactions[transactionCount] = Transaction(destination, value, false, data);
        transactionCount += 1;
        return transactionCount - 1;
    }

    function makeDough() payable external {
        //require user to have 1 of each ingredient
        
        //require contract to have at least 1 dough token left to give

        //take ingredient tokens from sender and add them back to the contract

        //give sender dough token 
        
        //add sender to the owners if they aren't already in there
        if(!isOwner(msg.sender)) {
            owners.push(msg.sender);
            //set new required amount to be 20 %
            // if 5% isn't a whole number, don't change the required number and check there are at least 10 owners
            if(owners.length / 5 % 1 == 0 && owners.length > 10) {
                required = owners.length / 5;
            }
        }
    } 

    constructor(address[] memory _owners, uint _confirmations) {
        require(_owners.length > 0);
        require(_confirmations > 0);
        require(_confirmations <= _owners.length);
        owners = _owners;
        required = _confirmations;
    }
}