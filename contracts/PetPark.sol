//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract PetPark {

    struct Borrower{
        uint age;
        uint gender;
        uint animalType;
        bool existing;
    }

    address owner;
    mapping(address => Borrower) borrowers; 
    uint[6] public animalCounts;

    event Added(uint animalType, uint animalCount);
    event Borrowed(uint animalType);
    event Returned(uint animalType);

    error noOwner(address addr);

    constructor(){
        owner=msg.sender;
    }

    modifier validAnimal(uint animalType){
        require(animalType>0 && animalType<6, "Invalid animal type");
        _;
    }
    modifier ownerOnly(address addr){
        require(addr==owner, "Not an owner");
        _;
    }

    modifier borrowRules(uint age, uint gender, uint animalType){
        Borrower storage borrower = borrowers[msg.sender];
        require(age>0, "Invalid Age");
        // No new-born babies. 1yo toddlers are fine. 
        // Though they are more likely to be looking to get adopted than be looking for pets to adopt.
        // No anti-causality. We aren't interested in your past lives either. 
        require(animalType>0 && animalType<6, "Invalid animal type");
        // In this world, only 5(+1) types of beings exist. 
        require(animalCounts[animalType]>uint(0), "Selected animal not available");
        // Oops, now you have one choice less. Try again.
        if(borrower.existing==true){
            require(borrower.age==age, "Invalid Age");
            // Pet park helps you ignore aging. Your age is written on the stone. I mean, on the ethereum.
            require(borrower.gender==gender, "Invalid Gender"); 
            // Pick one and be sure about it before you come across, please
        }
        require(borrower.animalType==uint(0), "Already adopted a pet");
        // You wanna build your own pet park? I can help you, but don't steal our pets. 
        
        // Now, some more meaningful rules. 
        if(gender==0 && !(animalType==1 || animalType==3)){
            revert("Invalid animal for men");
        }
        if(gender==1 && age<40){
            revert("Invalid animal for women under 40");
        }
        _;
    }

    

    function add(uint _animalType, uint _count) external ownerOnly(msg.sender) validAnimal(_animalType) {
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);        
    }

    function borrow(uint _age, uint _gender, uint _animalType) external borrowRules(_age,_gender,_animalType){
        Borrower storage borrower = borrowers[msg.sender];
        borrower.age = _age;
        borrower.gender = _gender;
        borrower.animalType = _animalType;
        borrower.existing = true;
        animalCounts[_animalType] -=1;
        console.log(animalCounts[_animalType]);
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        require(borrowers[msg.sender].animalType!=uint(0), "No borrowed pets");
        Borrower storage borrower = borrowers[msg.sender];
        uint animalType = borrower.animalType;
        animalCounts[animalType] += 1;
        borrower.animalType = 0;
        emit Returned(animalType);
    }


}