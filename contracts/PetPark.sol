//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    struct Borrower {
        uint gender;
        uint age;
        bool borrowed;
        uint currentAnimal;
    }

    // AnimalTypes are Fish (1), Cat (2), Dog (3), Rabbit (4), Parrot (5)
    mapping (uint => uint) animalsInPark;
    mapping (address => Borrower) borrowers;
    address public owner;

    event Added(uint indexed AnimalType, uint AnimalCount);
    event Borrowed(uint indexed AnimalType);
    event Returned(uint indexed AnimalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    function add(uint _animalType, uint _count) public onlyOwner {
        require((_animalType < 6) && (_animalType !=0), "Invalid animal");
        animalsInPark[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, uint _gender, uint _animalType) public {

        Borrower storage b = borrowers[msg.sender];

        require((_animalType < 6) && (_animalType != 0), "Invalid animal type");
        require((_age != 0), "Invalid Age");

        if (b.borrowed) {
            require((b.age == _age), "Invalid Age");
            require((b.gender == _gender), "Invalid Gender");
        }
        
        require((b.currentAnimal == 0), "Already adopted a pet");
        // Gender Male (0), Female (1)
        if (_gender == 0) {
            require((_animalType == 1) || (_animalType == 3), "Invalid animal for men");
        } else if (_age < 40) {
            require((_animalType != 2), "Invalid animal for women under 40");
        }

        require((animalsInPark[_animalType] > 0), "Selected animal not available");

        // if (b.currentAnimal != 0) {
        //     // give back an animal to borrow a new one
        //     giveBackAnimal();
        // }

        animalsInPark[_animalType] -= 1;
        b.currentAnimal = _animalType;

        if (!b.borrowed) {
            b.age = _age;
            b.gender = _gender;
            b.borrowed = true;
        }
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        Borrower storage b = borrowers[msg.sender];
        require(b.borrowed, "No borrowed pets");
        animalsInPark[b.currentAnimal] += 1;
        uint returnedAnimal = b.currentAnimal;
        b.currentAnimal = 0;
        emit Returned(returnedAnimal);
    }

    function animalCounts(uint _animalType) public view returns (uint) {
        return animalsInPark[_animalType];
    }
}
