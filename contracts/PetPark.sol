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

    address owner;
    mapping (AnimalType => uint) public animalCounts;
    mapping (address => AnimalType) public userBorrowed;
    mapping (address => uint) public ageOfUser;
    mapping (address => Gender) public genderOfUser;
    event Added (AnimalType animalType, uint count);
    event Returned (AnimalType animalType);
    event Borrowed (AnimalType animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier userHasBorrowedAnimalBefore () {
        require (userBorrowed[msg.sender] != AnimalType.None , "No borrowed pets");
        _;
    }

    function add(AnimalType _animalType, uint _count) external onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");
        animalCounts[_animalType] = _count;
        emit Added(_animalType, _count);
    }

    function giveBackAnimal() external userHasBorrowedAnimalBefore() {
        AnimalType animalType = userBorrowed[msg.sender];
        userBorrowed[msg.sender] = AnimalType.None;
        animalCounts[animalType]++;
        userBorrowed[msg.sender] = AnimalType.None;
        emit Returned(animalType);
    }

    function borrow (uint _age, Gender _gender, AnimalType _animalType) external {
        require(_gender == Gender.Male || _gender == Gender.Female, "Invalid Gender");
        require(_age > 0, "Invalid Age");
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(animalCounts[_animalType] != 0, "Selected animal not available");

        if (ageOfUser[msg.sender] != 0) {
            require(ageOfUser[msg.sender] == _age, "Invalid Age");
            require(genderOfUser[msg.sender] == _gender, "Invalid Gender");
            require(userBorrowed[msg.sender] == AnimalType.None, "Already adopted a pet");
        }

        if (_gender == Gender.Male) {
            require((_animalType == AnimalType.Dog || _animalType == AnimalType.Fish), "Invalid animal for men");
        }
        
        if (_gender == Gender.Female) {
            require(_age < 40 && _animalType != AnimalType.Cat, "Invalid animal for women under 40");            
        }



        animalCounts[_animalType]--;
        userBorrowed[msg.sender] = _animalType;
        ageOfUser[msg.sender] = _age;
        genderOfUser[msg.sender] = _gender;
        emit Borrowed(_animalType);
    }

}