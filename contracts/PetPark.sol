//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }
    enum Gender { Male, Female }
    struct Borrower {
         uint8 age;
         Gender gender;
         AnimalType animalType;
    }

    address private owner;
    mapping(AnimalType => uint256) public animalCounts;
    mapping(address => Borrower) private borrowing;

    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint256 _count) public {
        require(msg.sender == owner, "Not an owner");
        require(_animalType != AnimalType.None, "Invalid animal");

        animalCounts[_animalType] = _count;

        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) public {
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(_age > 0, "Invalid Age");
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        // Only people that have an age set, have ever borrowed an animal
        if (borrowing[msg.sender].age != 0) {
            // Throw an error if an address has called this function before using other values for Gender and Age.
            require(borrowing[msg.sender].age == _age, "Invalid Age");
            require(borrowing[msg.sender].gender == _gender, "Invalid Gender");
            // Can borrow only one animal at a time. Use function giveBackAnimal to borrow another animal.
            require(borrowing[msg.sender].animalType == AnimalType.None, "Already adopted a pet");
        }
        // Men can borrow only Dog and Fish.
        if (_gender == Gender.Male) {
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        }
        // Women can borrow every kind, but women aged under 40 are not allowed to borrow a Cat.
        if (_gender == Gender.Female && _age < 40) {
            require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }

        borrowing[msg.sender].age = _age;
        borrowing[msg.sender].gender = _gender;
        borrowing[msg.sender].animalType = _animalType;
        animalCounts[_animalType]--;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        // Throw an error if user hasn't borrowed before.
        require(borrowing[msg.sender].animalType != AnimalType.None, "No borrowed pets");

        AnimalType animalType = borrowing[msg.sender].animalType;
        borrowing[msg.sender].animalType = AnimalType.None;
        animalCounts[animalType]++;

        emit Returned(animalType);
    }

}
