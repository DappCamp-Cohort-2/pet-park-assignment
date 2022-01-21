//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    
    address owner;

    enum AnimalType {
        None,  
        Fish,   //AnimalType: 1
        Cat,    //AnimalType: 2
        Dog,    //AnimalType: 3
        Rabbit, //AnimalType: 4
        Parrot  //AnimalType: 5
    }

    enum Gender {
        Male,   //Gender: 0
        Female  //Gender: 1
    }   
    
    struct Borrower {
        uint age;
        Gender gender;
        AnimalType animaltype;
    }

    mapping(AnimalType => uint) public animalCounts;
    mapping(address => Borrower) public borrowerinfo;

    constructor () {
        owner = msg.sender;
    }

    event Added(AnimalType animaltype, uint count);
    event Borrowed(AnimalType animaltype);
    event Returned(AnimalType animaltype);

    // For the owner to add the count of an animal
    function add(AnimalType _animaltype, uint _count) external {
        require(msg.sender == owner, "Not an owner");
        require(_animaltype!= AnimalType.None, "Invalid animal");
        animalCounts[_animaltype] += _count;
        emit Added(_animaltype, _count);
    }  

    // For users to borrow a pet
    function borrow(uint _age, Gender _gender, AnimalType _animaltype) public {
        if(borrowerinfo[msg.sender].age!=0) {
            require(borrowerinfo[msg.sender].age==_age, "Invalid Age");
            require(borrowerinfo[msg.sender].gender==_gender, "Invalid Gender");
        } else {
        borrowerinfo[msg.sender].age=_age;
        borrowerinfo[msg.sender].gender=_gender;
        }
        require(borrowerinfo[msg.sender].animaltype==AnimalType.None, "Already adopted a pet");
        require(_animaltype!= AnimalType.None, "Invalid animal type");
        require(_age != 0, "Invalid Age");
        require(animalCounts[_animaltype] > 0, "Selected animal not available"); 
        if (_gender == Gender.Male) require(_animaltype == AnimalType.Fish || _animaltype == AnimalType.Dog, "Invalid animal for men");
        else require(_age >= 40 || (_age < 40 && _animaltype != AnimalType.Cat), "Invalid animal for women under 40");              
        
        borrowerinfo[msg.sender].animaltype=_animaltype;
        animalCounts[_animaltype] -= 1;
        emit Borrowed(_animaltype); 
    }
    
    // For borrowers to return a pet
    function giveBackAnimal() public {
        require(borrowerinfo[msg.sender].animaltype!=AnimalType.None, "No borrowed pets");
        animalCounts[borrowerinfo[msg.sender].animaltype] += 1;
        emit Returned(borrowerinfo[msg.sender].animaltype);
        borrowerinfo[msg.sender].animaltype=AnimalType.None;       
    }

}