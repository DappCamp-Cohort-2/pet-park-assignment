//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    address owner;
    mapping(address => uint) public borrower;
    mapping(uint256 => uint256) public animalCounts;
    mapping(address => uint256) usersAge;
    mapping(address => uint256) usersGender;

    constructor(){
        owner = msg.sender;
    }

    event Added(uint _id, uint _count);
    event Borrowed(uint _id);

    function add(uint _id, uint _count) public {
        require(msg.sender == owner, "Not an owner");
        require (_id > 0 && _id < 6, "Invalid animal");
        if (_id == 1){
            animalCounts[1] += 1;
        } else if (_id == 2){
            animalCounts[2] += 1;
        } else if (_id == 3){
            animalCounts[3] += 1;
        } else if (_id == 4){
            animalCounts[4] += 1;
        } else if (_id == 5){
            animalCounts[5] += 1;
        }
        emit Added(_id, _count);
    }

    function borrow(uint _age,uint _gender, uint _id) public {
        if (usersAge[msg.sender] == 0 && usersGender[msg.sender] == 0){
            usersAge[msg.sender] = _age;
            usersGender[msg.sender] = _gender;
        } else {
            require(usersAge[msg.sender] == _age, "Invalid Age");
            require(usersGender[msg.sender] == _gender, "Invalid Gender");
        }

        require(borrower[msg.sender] == 0, "Already adopted a pet");
        if (_gender == 1 && _age < 40 && _id == 2){
            revert("Invalid animal for women under 40");
        } else if (_gender == 0 && (_id == 2 || _id == 4 || _id == 5)){
            revert("Invalid animal for men");
        }
        require (_id > 0 && _id < 6, "Invalid animal type");
        require(_age > 0, "Invalid Age");
        

        if (_id == 1){
            require (animalCounts[1] > 0, "Selected animal not available");
            animalCounts[1] -= 1;
            borrower[msg.sender] = 1;
        } else if (_id == 2){
            require (animalCounts[2] > 0, "Selected animal not available");
            animalCounts[2] -= 1;
            borrower[msg.sender] = 2;
        } else if (_id == 3){
            require (animalCounts[3] > 0, "Selected animal not available");
            animalCounts[3] -= 1;
            borrower[msg.sender] = 3;
        } else if (_id == 4){
            require (animalCounts[4] > 0, "Selected animal not available");
            animalCounts[4] -= 1;
            borrower[msg.sender] = 4;
        } else if (_id == 5){
            require (animalCounts[5] > 0, "Selected animal not available");
            animalCounts[5] -= 1;
            borrower[msg.sender] = 5;
        }
        
        emit Borrowed(_id);
    }

    function giveBackAnimal() public{
        require(borrower[msg.sender] > 0, "No borrowed pets");
        if (borrower[msg.sender] == 1){
            animalCounts[1] += 1;
        } else if (borrower[msg.sender] == 2){
            animalCounts[2] += 1;
        } else if (borrower[msg.sender] == 3){
            animalCounts[3] += 1;
        } else if (borrower[msg.sender] == 4){
            animalCounts[4] += 1;
        } else if (borrower[msg.sender] == 5){
            animalCounts[5] += 1;
        }
        borrower[msg.sender] = 0;

    }

    // function animalCount(uint _id) public view returns (uint){
    //     if (_id == 1){
    //         return fishCount;
    //     } else if (_id == 2){
    //         return catCount;
    //     } else if (_id == 3){
    //         return dogCount;
    //     } else if (_id == 4){
    //         return rabbitCount;
    //     } else if (_id == 5){
    //         return parrotCount;
    //     } else {
    //         return 0;
    //     }

    // }

    function print() public returns (uint){
        return borrower[msg.sender];

    }

}