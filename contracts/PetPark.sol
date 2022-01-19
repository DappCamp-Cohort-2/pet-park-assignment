//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title A smart contract development exercise for Dappcamp 
/// @author Shunichiro Mimura
contract PetPark {

    address owner;
    mapping(int => int) animalCnt;
    mapping(address => bool) borrowed; 
    mapping(address => int) ownerToAnimal;
    mapping(address => int) addressAge;
    mapping(address => int) addressGender;
    mapping(address => bool) addressInfoSet;

    constructor() {
      owner = msg.sender;
    }

    modifier onlyOwner {
      require(msg.sender == owner, "Not an owner");
      _;
    }

    modifier invalidAnimal(int animalType) {
      require(1 <= animalType && animalType <= 5, "Invalid animal");
      _;
    }

    modifier invalidAnimalType(int animalType) {
      require(1 <= animalType && animalType <= 5, "Invalid animal type");
      _;
    }

    modifier invalidAge(int age) {
      require(1 <= age, "Invalid Age");
      _;
    }

    modifier invalidGender(int gender) {
      _;
    }

    modifier animalNotAvailable(int animalType) {
        require(animalCnt[animalType] > 0, "Selected animal not available");
        _;
    }

    modifier ageGenderRestriction(int age, int gender, int animalType) {
        if (gender == 0 && (animalType == 2 || animalType == 4 || animalType == 5)) {
            revert("Invalid animal for men");
        } else if (gender == 1 && (age < 40 && animalType == 2)) {
            revert("Invalid animal for women under 40");
        }
        _;
    }

    modifier alreadyAdopted() {
        require(!borrowed[msg.sender], "Already adopted a pet");
        _;
    }

    modifier notAdopted() {
        require(borrowed[msg.sender], "No borrowed pets");
        _;
    }
    
    modifier ageGenderVerification(int age, int gender) {
        if(addressInfoSet[msg.sender]) {
            require(addressAge[msg.sender] == age, "Invalid Age");
            require(addressGender[msg.sender] == age, "Invalid Gender");
        }
        _;
    }

    event Added(int animalType, int animalCount);
    event Borrowed(int animalType);

    /**
    Takes Animal Type and Count. Gives shelter to animals in our park.
    Only contract owner (address deploying the contract) should have access to this functionality.
    Emit event Added with parameters Animal Type and Animal Count.
    */
    function add(int256 animalType, int256 count) public onlyOwner invalidAnimal(animalType) {
        animalCnt[animalType] += count;
        emit Added(animalType, count);
    }

    /**
    Takes Age, Gender and Animal Type.
    Can borrow only one animal at a time. Use function giveBackAnimal to borrow another animal.
    Men can borrow only Dog and Fish.
    Women can borrow every kind, but women aged under 40 are not allowed to borrow a Cat.
    Throw an error if an address has called this function before using other values for Gender and Age.
    Emit event Borrowed with parameter Animal Type.
    */
    function borrow(int age, int gender, int animalType) public
        invalidAge(age) 
        invalidGender(gender)
        invalidAnimalType(animalType) 
        animalNotAvailable(animalType) 
        alreadyAdopted
        ageGenderVerification(age, gender)
        ageGenderRestriction(age, gender, animalType) {

            animalCnt[animalType]--;
            borrowed[msg.sender] = true;
            ownerToAnimal[msg.sender] = animalType;
            addressAge[msg.sender] = age;
            addressGender[msg.sender] = gender;
            addressInfoSet[msg.sender] = true;
            emit Borrowed(animalType);

    }

    /** 
    Throw an error if user hasn't borrowed before.
    Emit event Returned with parameter Animal Type. 
    */
    function giveBackAnimal() public notAdopted {
        borrowed[msg.sender] = false;
        int borrowedAnimalType = ownerToAnimal[msg.sender];
        animalCnt[borrowedAnimalType]++;
    }

    function animalCounts(int animalType) public view returns (int) {
        return animalCnt[animalType];
    }

}