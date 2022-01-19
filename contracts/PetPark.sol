//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;

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

    mapping(address => AnimalType) borrowedAnimals;
    mapping(address => bool) hasBorrowed;
    mapping(address => Gender) genders;
    mapping(address => uint8) ages;
    mapping(AnimalType => uint256) public animalCounts;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier isAnimalValid(AnimalType _animalType) {
        require(_animalType != AnimalType.None, "Invalid animal");
        _;
    }

    modifier checkAnimalType(AnimalType _animalType) {
        require(_animalType != AnimalType.None, "Invalid animal type");
        _;
    }

    modifier hasBorrowedPet() {
        AnimalType borrowedAnimal = borrowedAnimals[msg.sender];
        require(borrowedAnimal != AnimalType.None, "No borrowed pets");
        _;
    }

    modifier checkWomenRequirements(
        uint8 _age,
        Gender _gender,
        AnimalType _animalType
    ) {
        require(
            _gender == Gender.Male ||
                _age > 40 ||
                _animalType != AnimalType.Cat,
            "Invalid animal for women under 40"
        );
        _;
    }

    modifier checkMenRequirements(Gender _gender, AnimalType _animalType) {
        require(
            _gender == Gender.Female ||
                _animalType == AnimalType.Dog ||
                _animalType == AnimalType.Fish,
            "Invalid animal for men"
        );
        _;
    } 

    modifier invalidBorrowGender(Gender _gender) {
        require(
            !hasBorrowed[msg.sender] || genders[msg.sender] == _gender,
            "Invalid Gender"
        );
        _;
    }

    modifier invalidBorrowAge(uint8 _age) {
        require(
            !hasBorrowed[msg.sender] || ages[msg.sender] == _age,
            "Invalid Age"
        );
        _;
    }

    modifier requiresAge(uint8 _age) {
        require(_age > 0, "Invalid Age");
        _;
    }

    modifier hasNotAdoptedPet() {
        require(
            borrowedAnimals[msg.sender] == AnimalType.None,
            "Already adopted a pet"
        );
        _;
    }

        modifier isAnimalAvailable(AnimalType _animalType) {
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint256 _count)
        public
        onlyOwner
        isAnimalValid(_animalType)
    {
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(
        uint8 _age,
        Gender _gender,
        AnimalType _animalType
    )
        public
        checkWomenRequirements(_age, _gender, _animalType)
        invalidBorrowGender(_gender)
        invalidBorrowAge(_age)
        requiresAge(_age)
        hasNotAdoptedPet
        checkAnimalType(_animalType)
        isAnimalAvailable(_animalType)
         checkMenRequirements(_gender, _animalType)
    {
        
        animalCounts[_animalType] -= 1;
        borrowedAnimals[msg.sender] = _animalType;
        hasBorrowed[msg.sender] = true;
        genders[msg.sender] = _gender;
        ages[msg.sender] = _age;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public hasBorrowedPet {
        AnimalType borrowedAnimal = borrowedAnimals[msg.sender];
        animalCounts[borrowedAnimal] += 1;
        emit Returned(borrowedAnimal);
        borrowedAnimals[msg.sender] = AnimalType.None;
    }
}
