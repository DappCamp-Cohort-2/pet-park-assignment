//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {

    // fire an event to let the app know that Animal added
    event Added(uint animalType, uint count);

    // fire an event to let the app know that Animal borrowed
    event Borrowed(uint animalType);

    // fire an event to let the app know that Animal returned
    event Returned(uint animalType);

    address owner;
    
    mapping(uint => uint) public animalCounts;

    mapping(address => uint) public animalBorrowedByOwner;

     uint[] public validAnimals = [1,2,3,4,5];
    constructor() {
        owner = msg.sender;
    }

    struct Borrower {
        uint age;
        uint gender;
    }

    mapping(address => Borrower) public borrowers;

    function add(uint _animalType, uint _count) external {
        // Verify only Owner can add animal
        require(msg.sender == owner, "Not an owner");

        // verify animal is valid  
        require(isValidAnimal(_animalType), "Invalid animal");

       //increment the animal count in the park propotional to the animals donated
        animalCounts[_animalType] = animalCounts[_animalType] + _count;

       //emit the event that Animal addde to the park
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, uint _gender, uint _animalType) external {
        require(_age > 0, "Invalid Age");
    
        bool isValid = isValidAnimal(_animalType);
       
        require(isValid, "Invalid animal type");

        require(animalCounts[_animalType] > 0, "Selected animal not available");

        uint previouslyBorrowed = animalBorrowedByOwner[msg.sender];

        if(previouslyBorrowed >= 1){
            require(borrowers[msg.sender].age == _age, "Invalid Age");
            require(borrowers[msg.sender].gender == _gender, "Invalid Gender");
        }

        require(previouslyBorrowed != _animalType,  "Already adopted a pet");

        if(_gender == 0){
            require( _animalType == 1 || _animalType == 3, "Invalid animal for men"); 
        }
        else{
            require(_age > 40 && _animalType != 2, "Invalid animal for women under 40");
        }

        // borrow new animal and assign the animal to the borrower
        animalBorrowedByOwner[msg.sender] = _animalType;

        // subtract the animal count in the park
        animalCounts[_animalType] = animalCounts[_animalType] - 1;
    
         // save borrower details
        Borrower memory borrowerDetails = Borrower(_age,_gender);
        borrowers[msg.sender] =  borrowerDetails;

        emit Borrowed(_animalType);
   }


    function giveBackAnimal() public {
        // check if user has borrowed before
        require(animalBorrowedByOwner[msg.sender] >= 1, "No borrowed pets");

        //Get the previously borrowed animal type  
        uint previouslyBorrowed = animalBorrowedByOwner[msg.sender];
        
        // release the animal from the borrower
        animalBorrowedByOwner[msg.sender] = 0;
        
        // increment the animal count
         animalCounts[previouslyBorrowed] = animalCounts[previouslyBorrowed] + 1;

        emit Returned(previouslyBorrowed);
        
    }


    function isValidAnimal(uint _animalType) private returns (bool) {

        
        for (uint i; i < validAnimals.length; i++) {
         if(validAnimals[i] == _animalType){
             return true;
         }
        }

        return false;
        

    }



}