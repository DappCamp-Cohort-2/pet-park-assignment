//SPDX-License-Identifier:Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract PetPark {

address private _Owner;

//Type of Animals allowed in the pet park
enum  Animals{
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

// Borrower details
struct Borrower{
    uint8 Age;
    bool Borrowed;          // flag to check if the Borrower has borrowed an animal
    Gender genderType;
    Animals AnimalType;
}

mapping (Animals => uint) public animalCounts; // Map to store the count of each animal
mapping (address => Borrower) public BorrowerList;  // Map to store the borrower details for each address
event Added (Animals _AnimalType,uint _Count);
event Borrowed(Animals _AnimalType);
event Returned(Animals _AnimalType);

constructor() {
    // store the Contract Owners address
    _Owner = msg.sender;
}

function add(Animals _AnimalType, uint _Count) public {

    //Check if the caller is the Contract Owner
  	require(msg.sender==_Owner,"Not an owner");
    
    //Check if the Animal Type to be added is allowed
    require((_AnimalType >= Animals.Fish ) && (_AnimalType <= Animals.Parrot), "Invalid animal");

    //Add the animal to the park
    animalCounts[_AnimalType] += _Count;
    
    emit Added(_AnimalType,_Count);
    
}

function borrow(uint8 _Age, Gender _genderType, Animals _AnimalType ) public {
   
   // Check if Age is non zero
    require (_Age >0, "Invalid Age");

    // Revert if the Animal is not allowed
    if((_AnimalType < Animals.Fish) || (_AnimalType > Animals.Parrot))
    {
        revert("Invalid animal type");
    }
    
    //Throw an error if the Borrower is trying to borrow again using different Age/Gender
    if(BorrowerList[msg.sender].Borrowed == true){
       
        if (BorrowerList[msg.sender].Age != _Age)
        {
            revert("Invalid Age");
        }

        if(BorrowerList[msg.sender].genderType != _genderType)
        {
            revert("Invalid Gender");
        }
        revert("Already adopted a pet");
    }

    //Check to ensure Men can borrow only a Fish or a Dog
    if(_genderType == Gender.Male){
        require(((_AnimalType == Animals.Fish) || (_AnimalType == Animals.Dog)),"Invalid animal for men");
    }

    // Check to ensure Women under Age 40 cant borrow a cat
    if (( _genderType == Gender.Female) && (_Age < 40 ))
    {
        require(_AnimalType != Animals.Cat, "Invalid animal for women under 40");
    }

    // Check if the animal is available for borrowing         
    require (animalCounts[_AnimalType] >0, "Selected animal not available");
 
    // Animal's borrrowed 
    animalCounts[_AnimalType] --;

    //Update the Borrower details 
    BorrowerList[msg.sender].Borrowed = true;
    BorrowerList[msg.sender].AnimalType = _AnimalType;
    BorrowerList[msg.sender].Age = _Age;
    BorrowerList[msg.sender].genderType = _genderType;

    emit Borrowed(_AnimalType);
}


function giveBackAnimal() public{

    // No Animal has been borrowed yet
    if(BorrowerList[msg.sender].Borrowed == false){
    
        revert("No borrowed pets");
    }
    
    // Return the animal, update the count and Borrower details
    Animals _AnimalType = BorrowerList[msg.sender].AnimalType;
    animalCounts[_AnimalType] ++;
    BorrowerList[msg.sender].Borrowed = false;    
    BorrowerList[msg.sender].AnimalType = Animals.None;

    emit Returned(_AnimalType);

}

}