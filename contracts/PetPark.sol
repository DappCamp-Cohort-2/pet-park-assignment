//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// TODO: I would import differnetly if prod
import "./open-zeplin/ownable.sol";

contract PetPark is Ownable {
    event Added(uint256 animalType, uint256 count);

    function add(uint256 _animalType, uint256 _count) public onlyOwner {
        require(_animalType > 0, "Invalid animal");
        // TODO: Something?
        emit Added(_animalType, _count);
    }
}
