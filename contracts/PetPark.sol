//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Owner.sol";
import "./AnimalType.sol";
import "./Gender.sol";
import "hardhat/console.sol";

contract PetPark is Owner {

    struct Visitor {
        uint8 gender;
        uint age;
        bool exists;
    }

    mapping(address => Visitor) public visitorInfo;
    mapping(address => uint8) public borrowedAnimalType;
    uint[6] public petPark;

    event Added(uint8 indexed animalType, uint indexed count);
    event Borrowed(uint8 indexed animalType);
    event Returned(uint8 indexed animalType);

    function add(uint8 _animalType, uint _count) external isOwner isValidAnimalType(_animalType) {
        require(_animalType > 0 && _animalType <= 5, "Invalid animal");
        petPark[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    modifier isValidAnimalType(uint8 _animalType) {
        require(_animalType > 0 && _animalType <= 5, "Invalid animal");
        _;
    }

    function borrow(uint _age, uint8 _gender, uint8 _animalType) external {
        require(_age > 0, "Invalid Age");
        require(_animalType > 0 && _animalType <= 5, "Invalid animal type");
        require(animalCounts(_animalType) > 0, "Selected animal not available");
        if (visitorInfo[msg.sender].exists == true) {
            require(visitorInfo[msg.sender].age == _age, "Invalid Age");
            require(visitorInfo[msg.sender].gender == _gender, "Invalid Gender");
        } else {
            visitorInfo[msg.sender].age = _age;
            visitorInfo[msg.sender].gender = _gender;
            visitorInfo[msg.sender].exists = true;
        }
        require(borrowedAnimalType[msg.sender] == 0, "Already adopted a pet");

        if (_gender == 0) {
            canMenBorrow(_animalType);
        }

        if (_gender == 1) {
            canWomenBorrow(_age, _animalType);
        }

        if (borrowedAnimalType[msg.sender] > 0) {
            giveBackAnimal();
        }

        borrowedAnimalType[msg.sender] = _animalType;
        petPark[_animalType] -= 1;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        uint8 animalType = borrowedAnimalType[msg.sender];
        require(animalType > 0, "No borrowed pets");
        
        borrowedAnimalType[msg.sender] = 0;
        petPark[animalType] += 1;
        emit Returned(animalType);
    }

    function canMenBorrow(uint8 _animalType) internal pure {
        require(_animalType == 1 || _animalType == 3, "Invalid animal for men");
    }

    function canWomenBorrow(uint _age, uint8 _animalType) internal pure {
        if (_age < 40) {
            require(_animalType != 2, "Invalid animal for women under 40");
        }
    }

    function animalCounts(uint8 _animalType) public view returns (uint) {
        return petPark[_animalType];
    }
}
