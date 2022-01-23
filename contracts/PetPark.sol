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
        uint8 age;
        Gender gender;
    }

    //attributes
    address public owner; 
    mapping(address => Borrower) public borrowers;
    mapping(AnimalType => uint) public animalCounts;
    mapping(address => AnimalType) private borrowedAnimals; 

    //events
    event Added(AnimalType _animalType, uint _count);
    event Borrowed(AnimalType _animalType);
    event Returned(AnimalType _animalType);

    constructor(){
        owner = msg.sender;
    }

    //modifiers
    modifier onlyOwner(){
        require(owner == msg.sender, "Only contract owner allowed!");
        _;
    }

    modifier validAnimal(AnimalType _animalType){
        require(_animalType >= AnimalType.None && _animalType<=AnimalType.Rabbit, "invalid animal type!");
        _;
    }

    //functions 
    function add(AnimalType _animalType, uint _count) public onlyOwner validAnimal(_animalType){
        require(_count > 0, "Count should be great than zero");

        animalCounts[_animalType] +=  _count;
        emit Added(_animalType, _count);

    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) external validAnimal(_animalType){
        Borrower memory borrower = borrowers[msg.sender];
        require(_age > 0, "invalid age");
        require(borrower.age == _age, "invalid age");
        require(borrower.gender == _gender, "invalid gender");
        require(borrowedAnimals[msg.sender] == AnimalType.None, "Already adopted a pet");
        require(animalCounts[_animalType]>0, "selected animial not available");
    
        
        if (_gender == Gender.Male)
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "men can borrow cat and fisth only");
        else if (_gender == Gender.Female && _age < 40)
            require( _animalType != AnimalType.Cat, "woman below 40 can't boorow cat");

        borrowers[msg.sender] = Borrower(_age, _gender);
        animalCounts[_animalType]--;
        borrowedAnimals[msg.sender] = _animalType;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external{
        require( borrowedAnimals[msg.sender] != AnimalType.None, "No borrowed pet");

        AnimalType returnedAnimal = borrowedAnimals[msg.sender];
        borrowedAnimals[msg.sender] = AnimalType.None;
        animalCounts[returnedAnimal]++;

        emit Returned(returnedAnimal);

    }
}