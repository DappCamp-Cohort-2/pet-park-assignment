//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract PetPark {
    address owner;

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Borrower {
        Gender gender;
        uint age;
    }

    mapping(AnimalType => uint) petPark;
    mapping(address => AnimalType) borrowerAnimalType;
    mapping(address => Borrower) borrowerInfo;

    event Added(AnimalType _animalType, uint _count);
    event Borrowed(AnimalType _animalType);
    event Returned(AnimalType _animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint _count) public onlyOwner isValidAnimalType(_animalType) {
        petPark[_animalType] += _count;

        emit Added(_animalType, _count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType) public isValidAnimalType(_animalType) {
        require(_age > 0, "Invalid Age");
        require(borrowerInfo[msg.sender].gender == _gender || borrowerInfo[msg.sender].age == 0, "Invalid Gender.");
        require(borrowerInfo[msg.sender].age == _age || borrowerInfo[msg.sender].age == 0, "Invalid Age.");
        require(petPark[_animalType] > 0, "Selected animal not available");
        require(borrowerAnimalType[msg.sender] == AnimalType.None, "Already adopted a pet.");

        if (_gender == Gender.Male) {
            require (_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men.");
        }

        if (_gender == Gender.Female && _age < 40) {
            require (_animalType != AnimalType.Cat, "Invalid animal for women under 40.");
        }

        borrowerInfo[msg.sender] = Borrower(_gender, _age);
        petPark[_animalType] -= 1;
        borrowerAnimalType[msg.sender] = _animalType;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(borrowerAnimalType[msg.sender] != AnimalType.None, "No borrowed pets.");

        petPark[borrowerAnimalType[msg.sender]]++;

        // emit Returned(_animalType);
    }

    function animalCounts(AnimalType _animalType) public view returns (uint) {
        return petPark[_animalType];
    }
    // Using a function modifier for checking valid animal type
    modifier isValidAnimalType(AnimalType _animalType) {
        if (_animalType <= AnimalType.None || _animalType > AnimalType.Parrot) {
            revert("Invalid animal type.");
        }
        _;
    }
    // Using a function modifier for checking owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
        revert("Not an owner");
        }
        _;
    }

}