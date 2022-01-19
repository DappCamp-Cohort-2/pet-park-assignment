//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

address public owner;

    //Store the borrowers info
    struct PetBorrower {
        uint animal_type;
        uint count;
        uint age;
        uint gender;

    }

//event for when a new pet gets added
event Added(uint animal_type, uint count);
//event for when a pet gets borrowed
event Borrowed(uint animal_type);

//mapping of animal type to counts
mapping(uint => uint) public animalCounts;
//mapping of addresses to pet borrowed info
mapping(address => PetBorrower) public petsBorrowed;

//modifier to check that only the onwer can call a function
  modifier onlyOwner {
    require(msg.sender == owner, "Not an owner");
    _;
  }

//modifier to check if some has borrowed a pet
    modifier hasBorrowed {
    require(petsBorrowed[msg.sender].count > 0, "No borrowed pets");
    _;
  }

constructor () public {
   
   //owner is set to contract creator
    owner = msg.sender;
    //set animal counts to 0
    animalCounts[1] = 0;
    animalCounts[2] = 0;
    animalCounts[3] = 0;
    animalCounts[4] = 0;
    animalCounts[5] = 0;
  }

//adding an animal
function add(uint animal_type, uint count) public onlyOwner
{

//invalid animal choice
require(animal_type <= 5 && animal_type != 0 , "Invalid animal");
//increase animal count for valid choice
animalCounts[animal_type] += count;
//emit event
emit Added(animal_type, count);

}

//borrowing a pet
function borrow(uint age, uint gender, uint animal_type) public 
{

    //valid age check
    require(age != 0 , "Invalid Age");
    //invalid animal choice
    require(animal_type <= 5 && animal_type != 0 , "Invalid animal type");


       //if the borrower has already borrowed pet, checks to see if the age and gender match
       if(petsBorrowed[msg.sender].count != 0)
       {
         if(petsBorrowed[msg.sender].age != age){revert("Invalid Age");}
         if(petsBorrowed[msg.sender].gender != gender){revert("Invalid Gender");}

       }

        //if a pet has already been borrowed
        if(petsBorrowed[msg.sender].count != 0){
            revert("Already adopted a pet");
        }

         //invalid animal choice for a man
        if (gender == 0 && (animal_type != 3 && animal_type != 1)) {
            revert("Invalid animal for men");
        }

        //invalid animal choice for a woman under 40
        if (gender == 1 && age < 40 && animal_type == 2) {
            revert("Invalid animal for women under 40");
        }

        //animal is not available
        if (animalCounts[animal_type] == 0)
        {
            revert("Selected animal not available");

        }

//add to pets borrowed
petsBorrowed[msg.sender] = PetBorrower(animal_type, 1, age, gender);
//decrease pet availabiltiy counts
animalCounts[animal_type]--;
//event for borrowed pet
emit Borrowed(animal_type);

}

//returning a animal
function giveBackAnimal() public hasBorrowed
{
   //increase pet availabiltiy counts
   animalCounts[petsBorrowed[msg.sender].animal_type]++;

}

}