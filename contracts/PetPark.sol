//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;

    struct Animal {
        uint animalType;
    }

    Animal[] private animals;

    mapping (uint => uint) unborrowedAnimals;
    mapping (address => uint) borrowedAnimalByAddress;
    mapping (address => uint) addressToAge;
    mapping (address => uint) addressToGender;
    mapping (address => bool) hasSetAddressDetails;

    event Added(uint animalType, uint count);
    event Borrowed(uint animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validateAnimalTypeForAdd(uint animalType) {
        require(animalType > 0, "Invalid animal");
        require(animalType < 6, "Invalid animal");
        _;
    }

    modifier validateAnimalType(uint animalType) {
        require(animalType > 0, "Invalid animal type");
        require(animalType < 6, "Invalid animal type");
        _;
    }

    modifier hasNotBorrowedAnimal() {
        require(borrowedAnimalByAddress[msg.sender] == 0, "Already adopted a pet");
        _;
    }

    modifier validateAnimalTypeForBorrower(uint age, uint gender, uint animalType) {
        if (gender == 0) {
            require(animalType == 3 || animalType == 1, "Invalid animal for men");
        } else {
            require(age > 40 || animalType != 2, "Invalid animal for women under 40");
        }
        _;
    }

    modifier validateGender(uint gender) {
        require(gender == 0 || gender == 1, "Invalid gender");
        _;
    }

    modifier validateAge(uint age) {
        require(age != 0, "Invalid Age");
        _;
    }

    modifier hasBorrowedAnimal() {
        require(borrowedAnimalByAddress[msg.sender] != 0, "No borrowed pets");
        _;
    }
    
    modifier validateAnimalAvailable(uint animalType) {
        require(unborrowedAnimals[animalType] != 0, "Selected animal not available");
        _;
    }

    modifier validateOwnerDetails(uint age, uint gender) {
        require(!hasSetAddressDetails[msg.sender] || addressToAge[msg.sender] == age, "Invalid Age");
        require(!hasSetAddressDetails[msg.sender] || addressToGender[msg.sender] == gender, "Invalid Gender");
        _;
    }

    function _createAnimal(uint _animalType) private {
        animals.push(Animal(_animalType));
        unborrowedAnimals[_animalType] = unborrowedAnimals[_animalType] + 1;
    }

    function add(uint animalType, uint count) external onlyOwner validateAnimalTypeForAdd(animalType) {
        for (uint i = 0; i < count; i++) {
            _createAnimal(animalType);
        }
        emit Added(animalType, count);
    }

    function borrow(uint age, uint gender, uint animalType) external validateAge(age) validateAnimalType(animalType) validateAnimalAvailable(animalType) validateOwnerDetails(age, gender) hasNotBorrowedAnimal validateAnimalTypeForBorrower(age, gender, animalType) validateGender(gender) {
        addressToAge[msg.sender] = age;
        addressToGender[msg.sender] = gender;
        hasSetAddressDetails[msg.sender] = true;
        borrowedAnimalByAddress[msg.sender] = animalType;
        unborrowedAnimals[animalType] = unborrowedAnimals[animalType] - 1;
        emit Borrowed(animalType);
    }

    function animalCounts(uint animalType) external view returns(uint) {
        return unborrowedAnimals[animalType];
    }

    function giveBackAnimal() external hasBorrowedAnimal {
        uint animalType = borrowedAnimalByAddress[msg.sender];
        borrowedAnimalByAddress[msg.sender] = 0;
        unborrowedAnimals[animalType] = unborrowedAnimals[animalType] + 1;
    }
}