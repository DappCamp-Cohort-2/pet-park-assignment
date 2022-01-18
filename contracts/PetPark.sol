//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    address public owner;

    event Added(uint8 aType, uint256 count);
    event Returned(uint8 aType);
    event Borrowed(uint8 aType);

    mapping(address => mapping(uint8 => uint256)) public petPark;
    mapping(address => mapping(uint8 => uint256)) public borrowedPoolOf;
    mapping(address => uint256) public noOfBorrowedAnimals;
 
    mapping(address => uint8) public genderOf;
    mapping(address => uint32) public ageOf;

    constructor() {
            // Set the transaction sender as the owner of the contract.
            owner = msg.sender;
        }

    function add(uint8 _aType, uint256 _count) public {

        require(msg.sender == owner, "Not an owner");

        if(_aType == 0){
            revert("Invalid animal");
        }
        petPark[msg.sender][_aType] += _count;

        emit Added(_aType, _count);
    }

    function animalCounts(uint8 _aType) public view returns(uint256) {
        return petPark[msg.sender][_aType]; 
    }

    function borrow(uint32 _age, uint8 _gender, uint8 _aType) public {

        if(ageOf[msg.sender] == 0) {
            ageOf[msg.sender] = _age;
            genderOf[msg.sender] = _gender;
        }

        if(ageOf[msg.sender] != _age) {
            revert("Invalid Age");
        } else if(genderOf[msg.sender] != _gender) {
            revert("Invalid Gender");
        } 
        

        if(_age == 0){
            revert("Invalid Age");
        }

        if(_aType == 0){
            revert("Invalid animal type");
        }

        if(petPark[owner][_aType] == 0){
            revert("Selected animal not available");
        }

        

         if(noOfBorrowedAnimals[msg.sender] != 0){
            revert("Already adopted a pet");
        }

        if(_gender == 0){
            require(_aType == 1 || _aType ==3, "Invalid animal for men");
        } else  if(_gender == 1 && _age < 40 && _aType == 2){
            revert("Invalid animal for women under 40");
        }

       

        petPark[msg.sender][_aType]++;
        petPark[owner][_aType]--;
        borrowedPoolOf[msg.sender][_aType]++;
        noOfBorrowedAnimals[msg.sender]++;   
        
        emit Borrowed(_aType);

    }

    function giveBackAnimal() public {
        uint8 i;
        uint8 returnedAnimalType;

        require( noOfBorrowedAnimals[msg.sender] != 0, "No borrowed pets");

        for(i = 1; i <= 5; i++) {
            if(borrowedPoolOf[msg.sender][i] != 0){
              petPark[msg.sender][i]--;
              borrowedPoolOf[msg.sender][i]--;
              noOfBorrowedAnimals[msg.sender]--;
              petPark[owner][i]++;  
              returnedAnimalType = i;
            }
        }
        
        emit Returned(returnedAnimalType);

    }
}