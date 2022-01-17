//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    address owner;
    mapping(address => uint) public borrower;

    constructor(){
        owner = msg.sender;
    }

    event Added(uint _id, uint _count);
    event Borrowed(uint _id);

    uint fishCount = 0;
    uint catCount = 0;
    uint dogCount = 0;
    uint rabbitCount = 0;
    uint parrotCount = 0;


    function add(uint _id, uint _count) public {
        require(msg.sender == owner, "Not an owner");
        require (_id > 0 && _id < 6, "Invalid animal");
        if (_id == 1){
            fishCount += 1;
        } else if (_id == 2){
            catCount += 1;
        } else if (_id == 3){
            dogCount += 1;
        } else if (_id == 4){
            rabbitCount += 1;
        } else if (_id == 5){
            parrotCount += 1;
        }
        emit Added(_id, _count);
    }

    function borrow(uint _age,uint _gender, uint _id) public {
        require(borrower[msg.sender] == 0, "Already adopted a pet");
        if (_gender == 1 && _age < 40 && _id == 2){
            revert("Invalid animal for women under 40");
        } else if (_gender == 0 && (_id == 2 || _id == 4 || _id == 5)){
            revert("Invalid animal for men");
        }
        require (_id > 0 && _id < 6, "Invalid animal type");
        require(_age > 0, "Invalid Age");
        

        if (_id == 1){
            require (fishCount > 0, "Selected animal not available");
            fishCount -= 1;
            borrower[msg.sender] = 1;
        } else if (_id == 2){
            require (catCount > 0, "Selected animal not available");
            catCount -= 1;
            borrower[msg.sender] = 2;
        } else if (_id == 3){
            require (dogCount > 0, "Selected animal not available");
            dogCount -= 1;
            borrower[msg.sender] = 3;
        } else if (_id == 4){
            require (rabbitCount > 0, "Selected animal not available");
            rabbitCount -= 1;
            borrower[msg.sender] = 4;
        } else if (_id == 5){
            require (parrotCount > 0, "Selected animal not available");
            parrotCount -= 1;
            borrower[msg.sender] = 5;
        }
        
        emit Borrowed(_id);
    }

    function giveBackAnimal() public{
        require(borrower[msg.sender] > 0, "No borrowed pets");
        if (borrower[msg.sender] == 1){
            fishCount += 1;
        } else if (borrower[msg.sender] == 2){
            catCount += 1;
        } else if (borrower[msg.sender] == 3){
            dogCount += 1;
        } else if (borrower[msg.sender] == 4){
            rabbitCount += 1;
        } else if (borrower[msg.sender] == 5){
            parrotCount += 1;
        }
        borrower[msg.sender] = 0;

    }

    function animalCount(uint _id) public view returns (uint){
        if (_id == 1){
            return fishCount;
        } else if (_id == 2){
            return catCount;
        } else if (_id == 3){
            return dogCount;
        } else if (_id == 4){
            return rabbitCount;
        } else if (_id == 5){
            return parrotCount;
        } else {
            return 0;
        }

    }

    function print() public returns (uint){
        return borrower[msg.sender];

    }

}