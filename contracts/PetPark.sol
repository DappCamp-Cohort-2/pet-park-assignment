//SPDX-License-Identifier: Unlicense
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

    //types
    struct Borrower {
        uint age;
        Gender gender;
    }

    //attributes
    address public owner; 
    mapping(address => Borrower) public borrowers;
    mapping(AnimalType => uint) public animalCounts;  //how many animals per animal
    mapping(address => AnimalType) private borrowedAnimals;   

    //events
    event Added(AnimalType _animalType, uint _count);
    event Borrowed(AnimalType _animalType);
    event Returned(AnimalType _animalType);

    constructor(){
        owner = msg.sender;
    }

    //modifiers
    /*
    modifier onlyOwner(){
        require(owner == msg.sender, "Not an owner");
        _;
    }

    modifier validAnimal(AnimalType _animalType){
        require(_animalType >= AnimalType.None && _animalType<=AnimalType.Rabbit, "Invalid animal type");
        _;
    }*/
    // modifiers
    modifier validAnimalType(AnimalType _animalType) {
        require(_animalType > AnimalType.None && _animalType <= AnimalType.Parrot, "Invalid animal type");
        _;
    }

    modifier onlyOwner() {
         if(msg.sender != owner) {
            revert("Not an owner");
        }
        _;
    }

    //functions 
    function add(AnimalType _animalType, uint _count) external onlyOwner validAnimalType(_animalType) {
        require(_count > 0, "Count should be positive");
        animalCounts[_animalType] +=  _count;
        emit Added(_animalType, _count);

    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType) external validAnimalType(_animalType) {
        Borrower storage borrower = borrowers[msg.sender];
        if (borrower.age > 0){
            require(borrower.age == _age, "Invalid Age");
            require(borrower.gender == _gender, "Invalid Gender");
        }
        require(_age > 0, "Invalid Age");
        require(borrowedAnimals[msg.sender] == AnimalType.None, "Already adopted a pet");    
        if (_gender == Gender.Male)
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        else
            require( _animalType != AnimalType.Cat && _age >=40, "Invalid animal for women under 40");

        
        require(animalCounts[_animalType]>0, "Selected animal not available"); 

        borrowers[msg.sender] = Borrower(_age, _gender);
        animalCounts[_animalType]--;
        borrowedAnimals[msg.sender] = _animalType;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external{
        AnimalType returnedAnimal = borrowedAnimals[msg.sender];
        require( returnedAnimal != AnimalType.None, "No borrowed pets");

        borrowedAnimals[msg.sender] = AnimalType.None;
        animalCounts[returnedAnimal]++;

        emit Returned(returnedAnimal);
    }
}

