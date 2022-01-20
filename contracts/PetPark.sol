//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract PetPark {
    address private owner;

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

    // how many animals per animal type
    mapping(AnimalType => uint) park;
    
    // borrower address => how many animals types borrowed
    mapping(address => AnimalType) borrowerAnimalType;

    // keep track of borrower
    mapping(address => Borrower) borrowersInfo;

    event Added(AnimalType _animalType, uint _count);
    event Borrowed(AnimalType _animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint _count) public onlyOwner validAnimalType(_animalType) {
        park[_animalType] += _count;

        emit Added(_animalType, _count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType) public validAnimalType(_animalType) {
        require(_age > 0, "Invalid Age");
        require(borrowersInfo[msg.sender].gender == _gender || borrowersInfo[msg.sender].age == 0, "Invalid Gender");
        require(borrowersInfo[msg.sender].age == _age || borrowersInfo[msg.sender].age == 0, "Invalid Age");
        require(park[_animalType] > 0, "Selected animal not available");
        require(borrowerAnimalType[msg.sender] == AnimalType.None, "Already adopted a pet");
        if(_gender == Gender.Male) {
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        }
        if(_gender == Gender.Female && _age < 40) {
            require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }

        borrowersInfo[msg.sender] = Borrower(_gender, _age);
        park[_animalType] -= 1;
        borrowerAnimalType[msg.sender] = _animalType;

        emit Borrowed(_animalType);

    }

    function giveBackAnimal() public {
        require(borrowerAnimalType[msg.sender] != AnimalType.None, "No borrowed pets");

        park[borrowerAnimalType[msg.sender]]++;
    }

    function animalCounts(AnimalType _animalType) public view returns (uint) {
        return park[_animalType];
    }

    // modifiers
    modifier validAnimalType(AnimalType _animalType) {
        if(_animalType <= AnimalType.None || _animalType > AnimalType.Parrot) {
            revert("Invalid animal type");
        }
        _;
    }

    modifier onlyOwner() {
         if(msg.sender != owner) {
            revert("Not an owner");
        }
        _;
    }

}