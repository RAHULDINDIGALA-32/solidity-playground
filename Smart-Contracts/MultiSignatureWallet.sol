// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSig {
    address[] public owners;
    uint256 public required;

    constructor(address[] memory _owners, uint256 _confirmations) {
        require(_owners.length > 0);
        require(_confirmations > 0);
        require(_confirmations <= _owners.length);

        owners = _owners;
        required = _confirmations;
    }

    receive() external payable {}

    struct Transaction {
        address destination;
        uint256 value;
        bool executed;
        bytes data;
    }

    //mapping(uint256 => Transaction) public transactionStorage;
    Transaction[] public transactions;

    mapping(uint256 => mapping(address => bool)) public confirmations;

    function transactionCount() public view returns (uint256) {
        return transactions.length;
    }

    modifier onlyOwners() {
        uint256 totalOwners = owners.length;
        bool isOwner;

        for (uint256 i = 0; i < totalOwners; i++) {
            if (msg.sender == owners[i]) {
                isOwner = true;
                break;
            }
        }

        require(isOwner);

        _;
    }

    function addTransaction(
        address _destination,
        uint256 _value,
        bytes memory _data
    ) internal onlyOwners returns (uint256) {
        Transaction memory transaction = Transaction({
            destination: _destination,
            value: _value,
            executed: false,
            data: _data
        });

        transactions.push(transaction);

        return transactions.length - 1;
    }

    function confirmTransaction(uint256 _transactionId) public onlyOwners {
        confirmations[_transactionId][msg.sender] = true;

        if (isConfirmed(_transactionId)) {
            executeTransaction(_transactionId);
        }
    }

    function getConfirmationsCount(
        uint transactionId
    ) public view returns (uint256) {
        uint txnCount = 0;
        uint totalOwners = owners.length;

        for (uint256 i = 0; i < totalOwners; i++) {
            if (confirmations[transactionId][owners[i]] == true) {
                txnCount++;
            }
        }

        return txnCount;
    }

    function submitTransaction(
        address _destination,
        uint256 _value,
        bytes memory _data
    ) external onlyOwners {
        uint256 txnId = addTransaction(_destination, _value, _data);
        confirmTransaction(txnId);
    }

    function isConfirmed(uint _transactionId) public view returns (bool) {
        uint256 confirmationsCount = getConfirmationsCount(_transactionId);

        if (confirmationsCount >= required) {
            return true;
        }

        return false;
    }

    function executeTransaction(uint256 _transactionId) public onlyOwners {
        if (!isConfirmed(_transactionId)) {
            revert("No enough confirmations");
        }

        Transaction memory txn = transactions[_transactionId];

        (bool success, ) = (txn.destination).call{value: txn.value}(txn.data);
        require(success);

        transactions[_transactionId].executed = true;
    }
}
