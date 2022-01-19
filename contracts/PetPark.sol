//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Animal types ref:
//    Fish (AnimalType: 1)
//    Cat (AnimalType: 2)
//    Dog (AnimalType: 3)
//    Rabbit (AnimalType: 4)
//    Parrot (AnimalType: 5)

contract PetPark {
    // events

    event Added(uint _animalType, uint _count);
    event Borrowed(uint _animalType);
    event Returned(uint _animalType);

    // types

    struct Borrower {
        uint age;
        uint gender;
    }

    // attributes

    address public owner;
    mapping(uint => uint) public animalCounts;
    mapping(address => uint) private borrowedAnimals;
    mapping(address => Borrower) private borrowers;

    constructor() {
        owner = msg.sender;
    }

    // modifiers

    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    modifier validAnimal(uint _animalType) {
        require(_animalType >= 1 && _animalType <= 5, "Invalid animal type");
        _;
    }

    // methods

    function add(uint _animalType, uint _count) external onlyOwner validAnimal(_animalType) {
        require(_count > 0, "Count should be positive");

        animalCounts[_animalType] = animalCounts[_animalType] + _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, uint _gender, uint _animalType) external validAnimal(_animalType) {
        Borrower storage borrower = borrowers[msg.sender];
        if (borrower.age > 0) {
            require(borrower.age == _age, "Invalid Age");
            require(borrower.gender == _gender, "Invalid Gender");
        }

        require(_age > 0, "Invalid Age");
        require(borrowedAnimals[msg.sender] == 0, "Already adopted a pet");
        if (_gender == 0)
            require(_animalType == 3 || _animalType == 1, "Invalid animal for men");
        else
            require(_animalType != 2 || _age >= 40, "Invalid animal for women under 40");
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        if (borrower.age == 0)
            borrowers[msg.sender] = Borrower(_age, _gender);

        animalCounts[_animalType]--;
        borrowedAnimals[msg.sender] = _animalType;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        uint borrowedAnimal = borrowedAnimals[msg.sender];
        require(borrowedAnimal > 0, "No borrowed pets");

        animalCounts[borrowedAnimal]++;
        borrowedAnimals[msg.sender] = 0;

        emit Returned(borrowedAnimal);
    }
}