// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0; //this is solidity version

contract DeadMansSwitch {
    address public owner;
    address public beneficiary;
    uint256 public lastBlock; // The block number of the last time the owner interacted
    uint256 public gracePeriod; // Number of blocks after which the transfer occurs

    // Event to log when the balance is sent to the beneficiary
    event FundsTransferred(address beneficiary, uint256 amount);

    constructor(address _beneficiary) {
        owner = msg.sender;
        beneficiary = _beneficiary;
        gracePeriod = 10; // Grace period set to 10 blocks
        lastBlock = block.number;
    }

    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    // Function for the owner to call and show they are still alive
    function still_alive() external onlyOwner {
        lastBlock = block.number; // Update the last block number
    }

    // Function to check and transfer funds if the owner hasn't called `still_alive` in the last 10 blocks
    function checkAndTransfer() external {
        // If the owner has not called still_alive() in the last 10 blocks, trigger the transfer
        if (block.number > lastBlock + gracePeriod) {
            uint256 balance = address(this).balance;
            require(balance > 0, "No funds to transfer.");
            payable(beneficiary).transfer(balance);
            emit FundsTransferred(beneficiary, balance);
        }
    }

    // Function to allow the contract to accept Ether
    receive() external payable {}

    // Fallback function in case someone sends Ether without data
    fallback() external payable {}
}
