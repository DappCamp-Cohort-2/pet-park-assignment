
//SPDX-License-Identifier:Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract PetPark {

address Owner;

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

struct Borrower{
    bool Called;
    uint8 Age;
    bool Borrowed;
    Gender genderType;
    Animals AnimalType;
}

mapping (Animals => uint256) public AnimalCount;
mapping (address => Borrower) public BorrowerList;
event Added (Animals _AnimalType,uint _Count);
event Borrowed(Animals _AnimalType);
event Returned(Animals _AnimalType);

constructor() {
    Owner = msg.sender;
}

function add(Animals _AnimalType, uint _Count) public {

  	require(msg.sender==Owner,"Not an owner");
    
    require((_AnimalType >= Animals.Fish ) && (_AnimalType <= Animals.Parrot), "Invalid animal");

    AnimalCount[_AnimalType] += _Count;
    
    emit Added(_AnimalType,_Count);
    
}

function borrow(uint8 Age, Gender _genderType, Animals _AnimalType ) public {
   
    require (Age >0, "Invalid Age");

    if(BorrowerList[msg.sender].Borrowed == true){
       

        if (BorrowerList[msg.sender].Age != Age)
        {
            revert("Invalid Age");
        }

        if(BorrowerList[msg.sender].genderType != _genderType)
        {
            revert("Invalid Gender");
        }
        revert("Already adopted a pet");
    }

    BorrowerList[msg.sender].Called = true;
    BorrowerList[msg.sender].Age = Age;
    BorrowerList[msg.sender].genderType = _genderType;
    
    if((_AnimalType < Animals.Fish) || (_AnimalType > Animals.Parrot))
    {
        revert("Invalid animal type");
    }

    require (AnimalCount[_AnimalType] >0, "Selected animal not available");


     if(_genderType == Gender.Male){
        require(((_AnimalType == Animals.Fish) || (_AnimalType == Animals.Dog)),"Invalid animal for men");
    }

    if (( _genderType == Gender.Female) && (Age < 40 ))
    {
        require(_AnimalType != Animals.Cat, "Invalid animal for women under 40");
    }
 
    AnimalCount[_AnimalType] --;

    BorrowerList[msg.sender].Borrowed = true;
    BorrowerList[msg.sender].AnimalType = _AnimalType;

    emit Borrowed(_AnimalType);
}

function giveBackAnimal(Animals _AnimalType) public{

    if(BorrowerList[msg.sender].Borrowed == false){
    
        revert("No borrowed pets");
    }
    
    AnimalCount[_AnimalType] ++;
    
    BorrowerList[msg.sender].Called = false;
    BorrowerList[msg.sender].Age = 0;
    BorrowerList[msg.sender].Borrowed = false;
    BorrowerList[msg.sender].genderType = Gender.Male;
    BorrowerList[msg.sender].AnimalType = Animals.None;

    emit Returned(_AnimalType);

}

function animalCounts(Animals _AnimalType) public returns (uint256 )
{
    return AnimalCount[_AnimalType];
}
}