//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    struct PetOwner {
        AnimalType borrowedAnimal;
        bool hasBorrowed;
        Gender gender;
        uint8 age;
    }

    event Added(AnimalType _animalType, uint256 _count);
    event Borrowed(AnimalType _animalType);
    event Returned(AnimalType _animalType);

    address private owner;
    mapping(address => PetOwner) petOwners;
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
        PetOwner storage petOwner = petOwners[msg.sender];

        require(_age > 0, "Invalid Age");
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(!petOwner.hasBorrowed || petOwner.gender == _gender, "Invalid Gender");
        require(!petOwner.hasBorrowed || petOwner.age == _age, "Invalid Age");
        require(petOwner.borrowedAnimal == AnimalType.None, "Already adopted a pet" );
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        require(_gender != Gender.Male || _animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        require(_gender != Gender.Female || _age > 40 || _animalType != AnimalType.Cat, "Invalid animal for women under 40");

        animalCounts[_animalType] -= 1;
        petOwner.borrowedAnimal = _animalType;
        petOwner.hasBorrowed = true;
        petOwner.gender = _gender;
        petOwner.age = _age;
        
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        AnimalType borrowedAnimal = petOwners[msg.sender].borrowedAnimal;
        require(borrowedAnimal != AnimalType.None, "No borrowed pets");
        animalCounts[borrowedAnimal] += 1;
        emit Returned(borrowedAnimal);
        petOwners[msg.sender].borrowedAnimal = AnimalType.None;
    }
}
