//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title A pet park for borrowing pets
/// @author Marci Detwiller
/// @notice Borrow pets but only one at a time!
contract PetPark {

    struct Borrower {
        uint gender;
        uint age;
        bool borrowed;
        uint currentAnimal;
    }

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

    /// @param _animalType: Animal types are Fish (1), Cat (2), Dog (3), Rabbit (4), Parrot (5)
    /// @param _count: Number to add
    function add(uint _animalType, uint _count) public onlyOwner {
        require((_animalType < 6) && (_animalType !=0), "Invalid animal");
        animalsInPark[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    /// @param _age: Age of borrower
    /// @param _gender: Gender of borrower (Male = 0, Female = 1)
    /// @param _animalType: Animal types are Fish (1), Cat (2), Dog (3), Rabbit (4), Parrot (5)
    function borrow(uint _age, uint _gender, uint _animalType) public {
        Borrower storage b = borrowers[msg.sender];

        require((_animalType < 6) && (_animalType != 0), "Invalid animal type");
        require((_age != 0), "Invalid Age");

        if (b.borrowed) {
            require((b.age == _age), "Invalid Age");
            require((b.gender == _gender), "Invalid Gender");
        }
        
        require((b.currentAnimal == 0), "Already adopted a pet");

        if (_gender == 0) {
            require((_animalType == 1) || (_animalType == 3), "Invalid animal for men");
        } else if (_age < 40) {
            require((_animalType != 2), "Invalid animal for women under 40");
        }

        require((animalsInPark[_animalType] > 0), "Selected animal not available");

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
        require((b.currentAnimal != 0), "No borrowed pets");
        animalsInPark[b.currentAnimal] += 1;
        uint returnedAnimal = b.currentAnimal;
        b.currentAnimal = 0;
        emit Returned(returnedAnimal);
    }

    /// @param _animalType: Animal types are Fish (1), Cat (2), Dog (3), Rabbit (4), Parrot (5)
    /// @return The number of animals of that type available in the park.
    function animalCounts(uint _animalType) public view returns (uint) {
        return animalsInPark[_animalType];
    }
}
