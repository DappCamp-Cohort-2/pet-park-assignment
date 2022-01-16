//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

uint256 constant MALE = 0;
uint256 constant FEMALE = 1;

uint256 constant FISH = 1;
uint256 constant CAT = 2;
uint256 constant DOG = 3;
uint256 constant RABBIT = 4;
uint256 constant PARROT = 5;

contract PetPark {
    address private owner;    

    mapping(uint256 => uint256) public animalCounts;
    mapping(address => uint256) borrowedAnimal;
    mapping(address => uint256) ageOfUsers;
    mapping(address => uint256) genderOfUsers;

    event Added(uint256 _animalType, uint256 _count);
    event Borrowed(uint256 _animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(uint256 _animalType, uint256 _count) external {
        require(msg.sender == owner, "Not an owner");
        require(_animalType >= 1 && _animalType <= 6, "Invalid animal");
        animalCounts[_animalType] = animalCounts[_animalType] + _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint256 _age, uint256 _gender, uint256 _animalType) external {
        require(_age > 0, "Invalid Age");
        require(_gender == MALE || _gender == FEMALE, "Invalid Gender");
        require(_animalType >= 1 && _animalType <= 6, "Invalid animal type");       
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        
        bool ageAlreadyRecorded = false;
        if(ageOfUsers[msg.sender] != 0) {
            require(ageOfUsers[msg.sender] == _age, "Invalid Age");
            require(genderOfUsers[msg.sender] == _gender, "Invalid Gender");
            ageAlreadyRecorded = true;
        }

        require(borrowedAnimal[msg.sender] == 0, "Already adopted a pet");    

        if (_gender == MALE) require(_animalType == FISH || _animalType == DOG, "Invalid animal for men");
        else require(!(_age < 40 && _animalType == CAT),"Invalid animal for women under 40");    
        
        if(!ageAlreadyRecorded){ 
            ageOfUsers[msg.sender] = _age;
            genderOfUsers[msg.sender] = _gender;
        }
        animalCounts[_animalType] = animalCounts[_animalType] - 1;
        borrowedAnimal[msg.sender] = _animalType;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        uint256 tempBorrowedAnimal = borrowedAnimal[msg.sender];
        require(tempBorrowedAnimal != 0, "No borrowed pets");       
        animalCounts[tempBorrowedAnimal] = animalCounts[tempBorrowedAnimal] + 1;
        borrowedAnimal[msg.sender] = 0;
    }
   
}
