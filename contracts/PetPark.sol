//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    
    address owner;

    uint public constant Fish = 1;       //AnimalType: 1
    uint public constant Cat = 2;        //AnimalType: 2
    uint public constant Dog = 3;        //AnimalType: 3
    uint public constant Rabbit = 4;     //AnimalType: 4
    uint public constant Parrot = 5;     //AnimalType: 5
    uint public constant Male = 0;       //Gender: 0
    uint public constant Female = 1;     //Gender: 1
    
    mapping(uint => uint) public animalCounts;
    mapping(address => uint) public age;
    mapping(address => uint) public gender;
    mapping(address => uint) public animaltype;

    constructor () {
        owner = msg.sender;
    }

    event Added(uint animaltype, uint count);
    event Borrowed(uint animaltype);
    event Returned(uint animaltype);

    // For the owner to add the count of an animal
    function add(uint _animaltype, uint _count) public {
        require(msg.sender == owner, "Not an owner");
        require(_animaltype >= 1 && _animaltype <=5, "Invalid animal");
        animalCounts[_animaltype] += _count;
        emit Added(_animaltype, _count);
    }  

    // For users to borrow a pet
    function borrow(uint _age, uint _gender, uint _animaltype) public {
        if(age[msg.sender]!=0) {
            require(age[msg.sender]==_age, "Invalid Age");
            require(gender[msg.sender]==_gender, "Invalid Gender");
        } else {
        age[msg.sender]=_age;
        gender[msg.sender]=_gender;
        }
        require(animaltype[msg.sender]==0, "Already adopted a pet");
        require(_animaltype >= 1 && _animaltype <=5, "Invalid animal type");
        require(_age != 0, "Invalid Age");
        require(animalCounts[_animaltype] > 0, "Selected animal not available"); 
        if (_gender == 0) require(_animaltype == 1 || _animaltype == 3, "Invalid animal for men");
        else require(_age >= 40 || (_age < 40 && _animaltype != 2), "Invalid animal for women under 40");              
        
        animaltype[msg.sender]=_animaltype;
        animalCounts[_animaltype] -= 1;
        emit Borrowed(_animaltype); 
    }
    
    // For borrowers to return a pet
    function giveBackAnimal() public {
        require(animaltype[msg.sender]!=0, "No borrowed pets");
        animalCounts[animaltype[msg.sender]] += 1;
        emit Returned(animaltype[msg.sender]);
        animaltype[msg.sender]=0;       
    }

}