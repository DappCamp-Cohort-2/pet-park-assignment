//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

uint constant FISH = 1;
uint constant CAT = 2;
uint constant DOG = 3;
uint constant RABBIT = 4;
uint constant PARROT = 5;

uint constant MALE = 0;
uint constant FEMALE = 1;

contract PetPark {
    // Mapping representing the count of each animal in the park
    mapping(uint => uint) public animalCounts;
    
    address owner;
    // The address that deploys contract will be the owner
    constructor() {
        owner = msg.sender;
    }

    // Event for Addition
    event Added(uint _type, uint _count);

    /* 
        Adds animals
        Takes an Animal Type and a Count
        Only the owner can add animals
    */ 
    function add(uint _type, uint _count) public whenValidType(_type){
        require(msg.sender == owner, "Not an owner");
        animalCounts[_type] += _count;
        emit Added(_type, _count);
    }

    // Mapping representing number of animals currently borrowed
    mapping(address => uint) public borrowedAnimals;
    mapping(address => uint) public borrowedAnimalType;

    // Mappings representing the address and the first Gender and Age they provide to avoid misuse
    mapping(address => uint) public addressGender;
    mapping(address => uint) public addressAge;

    // Mapping representing whether an address and age have been set
    mapping(address => bool) public addressGenderSet;
    mapping(address => bool) public addressAgeSet;

    // Event for borrowing
    event Borrowed(uint _type);

    // Modifier to enforce a valid type in our two functions that use type
    modifier whenValidType(uint _type) {
        // Require a valid animal type
        require(_type > 0 && _type < 6, "Invalid animal type");
        _;
    }

    /*
        Borrows an animal from the park
    */
    function borrow(uint _age, uint _gender, uint _type) public whenValidType(_type){

        // Have to be older than 0
        require(_age > 0, "Invalid Age");
        
        // The animal has to be available at the park
        require(animalCounts[_type] >0, "Selected animal not available");

        // Throw an error if this address has called the function before with a different gender or age
        // Store the gender and age of this address in our mapping
        require (addressGenderSet[msg.sender] == false || addressGender[msg.sender] == _gender, "Invalid Gender");
        require (addressAgeSet[msg.sender] == false || addressAge[msg.sender] == _age, "Invalid Age");
        
        if (addressGenderSet[msg.sender] == false || addressAgeSet[msg.sender] == false){
            addressGender[msg.sender] = _gender;
            addressGenderSet[msg.sender] = true;
            addressAge[msg.sender] = _age;
            addressAgeSet[msg.sender] = true;
        }

        // Can only borrow if no animals already borrowed
        require(borrowedAnimals[msg.sender] == 0, "Already adopted a pet");

        // Men can only borrow a dog or a fish
        if (_gender == FEMALE){
            if (_age < 40 && _type == CAT){
                // CANNOT BORROW
                revert("Invalid animal for women under 40");
            }
            else {
                // borrow
                borrowedAnimals[msg.sender] = 1;
                borrowedAnimalType[msg.sender] = _type;
                animalCounts[_type] -= 1;
                emit Borrowed(_type);
            }
        }
        else if ((_gender == MALE && _type == DOG) || (_gender == MALE && _type == FISH)) {
            // Borrow
            borrowedAnimals[msg.sender] = 1;
            borrowedAnimalType[msg.sender] = _type;
            animalCounts[_type] -= 1;
            emit Borrowed(_type);    
        } else {
            // cannot borrow
            revert("Invalid animal for men");
        }
    }

    // Event for returning
    event Returned(uint _type);

    /*
        Returns an animal to the shelter, whichever has been borrowed
        Throws an error if the user hasn't borrowed before
    */
    function giveBackAnimal() public {
        require (borrowedAnimals[msg.sender] > 0, "No borrowed pets.");
        uint animalType = borrowedAnimalType[msg.sender];
        animalCounts[animalType] ++;
        borrowedAnimals[msg.sender] --;
        emit Returned(animalType);
    }
}