//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address public owner;
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Man,
        Woman
    }

    // Unsure if better to have many mappings
    // or one mapping => array[hasCalled, Age, Gender, Animal];
    // or one for hasCalled, and then one for [Age, Gender, Animal];
    mapping(address => bool) borrowerHasCalled;
    mapping(address => uint) borrowerAge;
    mapping(address => uint8) borrowerGender;
    mapping(address => uint8) borrowedAnimal;

    uint[6] public animalCounts; 

    event Added(AnimalType animalType, uint animalCount);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint _count) public onlyOwner isValidAnimal(_animalType) {
        // TODO: should use safemath instead 
        animalCounts[uint(_animalType)] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType ) public isValidAnimal(_animalType) {
        // Sanity
        require(_age > 0, "Invalid Age");

        // Registration
        if (borrowerHasCalled[msg.sender]) {
            // Check that their call matches registration
            require(borrowerAge[msg.sender] == _age, "Invalid Age");
            require(borrowerGender[msg.sender] == uint8(_gender), "Invalid Gender");
        } else {
            // Otherwise register them
            borrowerHasCalled[msg.sender] = true;
            borrowerAge[msg.sender] = _age;
            borrowerGender[msg.sender] = uint8(_gender);
        }

        // Borrowing rules
        require(borrowedAnimal[msg.sender] == uint8(AnimalType.None), "Already adopted a pet");
        if (_gender == Gender.Man) {
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        }
        if (_gender == Gender.Woman && _age < 40) {
            require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }

        // Check if we have animal in stock
        require(animalCounts[uint(_animalType)] > 0, "Selected animal not available");
        
        // Passed all checks, let them borrow
        animalCounts[uint(_animalType)] -= 1;
        borrowedAnimal[msg.sender] = uint8(_animalType);
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        AnimalType _borrowedAnimal = AnimalType(borrowedAnimal[msg.sender]);
        require(_borrowedAnimal != AnimalType.None, "No borrowed pets");

        // Take back animal
        borrowedAnimal[msg.sender] = uint8(AnimalType.None);
        animalCounts[uint(_borrowedAnimal)] += 1;
        emit Returned(_borrowedAnimal);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    modifier isValidAnimal(AnimalType _animalType) {
        require(_animalType != AnimalType.None && uint(_animalType) <= uint(AnimalType.Parrot), "Invalid animal type");
        _;
    }
}