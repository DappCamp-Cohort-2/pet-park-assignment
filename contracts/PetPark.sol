//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {

    struct Borrower {
        uint age;
        uint gender;
        uint borrowCount;
        uint borrowedAnimalType;
        uint hasBorrowed;
    }

    address private owner;
    mapping(uint => uint)  public animalCounts;
    mapping(address => Borrower) public borrowedAnimals;

    // Defining a constructor
    constructor() public {
        owner = msg.sender;
        animalCounts[1] = 0;
        animalCounts[2] = 0;
        animalCounts[3] = 0;
        animalCounts[4] = 0;
        animalCounts[5] = 0;

    }

    //events
    event Added(uint _animalType, uint _count);
    event Borrowed(uint _animalType);
    event Returned(uint _animalType);

    modifier onlyOwner(){
        require(msg.sender == owner, "Not an owner");
        _;
    }


    function add(uint _animalType, uint _count) onlyOwner() external {
        if (_animalType < 1 || _animalType > 5) {
            revert("Invalid animal");
        }
        animalCounts[_animalType] = animalCounts[_animalType] + _count;
        emit Added(_animalType, animalCounts[_animalType]);
    }


    function borrow(uint _age, uint _gender, uint _animalType) external {
        if (_animalType < 1 || _animalType > 5) {
            revert("Invalid animal type");
        }
        require(_age > 0, "Invalid Age");
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        if (borrowedAnimals[msg.sender].hasBorrowed == 1) {
            require(_age == borrowedAnimals[msg.sender].age, "Invalid Age");
            require(_gender == borrowedAnimals[msg.sender].gender, "Invalid Gender");

        }
        require(borrowedAnimals[msg.sender].borrowCount == 0, "Already adopted a pet");

        //conditions for male
        if (_gender == 0) {
            if (!(_animalType == 1 || _animalType == 3)) {
                revert("Invalid animal for men");
            }
        }

        //conditions for female
        if (_gender == 1) {
            if (_age < 40 && _animalType == 2) {
                revert("Invalid animal for women under 40");
            }
        }

        borrowedAnimals[msg.sender] = Borrower(_age, _gender, 1, _animalType, 1);
        animalCounts[_animalType]--;
        emit Borrowed(_animalType);

    }

    function giveBackAnimal() public {
        require(borrowedAnimals[msg.sender].borrowCount == 1, "No borrowed pets");
        borrowedAnimals[msg.sender].borrowCount = 0;
        animalCounts[borrowedAnimals[msg.sender].borrowedAnimalType]++;
        emit Returned(borrowedAnimals[msg.sender].borrowedAnimalType);
    }

}