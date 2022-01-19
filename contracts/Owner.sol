// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Owner {

    address private owner;
    
    modifier isOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
}
