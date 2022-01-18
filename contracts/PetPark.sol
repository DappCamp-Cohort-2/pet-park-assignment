//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract PetPark {
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

    event Added(AnimalType _animalType, uint256 _count);
    event Borrowed(AnimalType _animalType);
    event Returned(AnimalType _animalType);

    address owner;
    mapping(address => AnimalType) borrowedAnimals;
    mapping(address => bool) hasBorrowed;
    mapping(address => Gender) genders;
    mapping(address => uint8) ages;
    mapping(AnimalType => uint256) public animalCounts;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint256 _count) public onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");

        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType ) public {
        require(_age > 0, "Invalid Age");
        require(!hasBorrowed[msg.sender] || genders[msg.sender] == _gender, "Invalid Gender");
        require(!hasBorrowed[msg.sender] || ages[msg.sender] == _age, "Invalid Age");
        require(borrowedAnimals[msg.sender] == AnimalType.None, "Already adopted a pet" );
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        require(_gender == Gender.Female || _animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        require(_gender == Gender.Male || _age > 40 || _animalType != AnimalType.Cat, "Invalid animal for women under 40");

        animalCounts[_animalType] -= 1;
        borrowedAnimals[msg.sender] = _animalType;
        hasBorrowed[msg.sender] = true;
        genders[msg.sender] = _gender;
        ages[msg.sender] = _age;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        AnimalType borrowedAnimal = borrowedAnimals[msg.sender];
        require(borrowedAnimal != AnimalType.None, "No borrowed pets");
        animalCounts[borrowedAnimal] += 1;
        emit Returned(borrowedAnimal);
        borrowedAnimals[msg.sender] = AnimalType.None;
    }
}
