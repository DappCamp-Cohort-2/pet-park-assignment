//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    enum AnimalType { NONE, FISH, CAT, DOG, RABBIT, PARROT }
    enum GenderType { MALE, FEMALE }
    mapping(AnimalType => uint) animals;
    address public owner = msg.sender; // Set the transaction sender as the owner of the contract.

    struct Borrower {
        uint8 age;
        GenderType gender;       
        AnimalType animal; 
    }
    mapping(address => Borrower) borrowers;

    // Events declaration
    event Added(AnimalType, uint);
    event Borrowed(AnimalType);
    event Returned(AnimalType);

    function PerPark() public {
        animals[AnimalType.FISH] = 0;
        animals[AnimalType.CAT] = 0;
        animals[AnimalType.DOG] = 0;
        animals[AnimalType.RABBIT] = 0;
        animals[AnimalType.PARROT] = 0;
    }

    // Modifier to check that the caller is the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to execute the rest of the code.
        _;
    }

    function add(AnimalType _type, uint _count)
        public
    {
        if(msg.sender != owner)
            revert("Not an owner");

        if(_type == AnimalType.NONE)
            revert("Invalid animal");

        animals[_type] += _count;
        emit Added(_type, _count);
    }

    function borrow(uint8 _age, GenderType _gender, AnimalType _type)
        public
    {
        if(_age == 0)
            revert("Invalid Age");

        if(_type == AnimalType.NONE)
            revert("Invalid animal type");

        if(animals[_type] == 0)
            revert("Selected animal not available");

        if(borrowers[msg.sender].age != 0)
            revert("Already adopted a pet");

        if(_gender == GenderType.MALE) {
            if(_type != AnimalType.DOG && _type != AnimalType.FISH)
                revert("Invalid animal for men");
        }        

        if(_gender == GenderType.FEMALE) {
            if(borrowers[msg.sender].age < 40 && _type == AnimalType.CAT)
                revert("Invalid animal for women under 40");
        }

        if(borrowers[msg.sender].age != _age)
            revert("Invalid Age");
        
        if(borrowers[msg.sender].gender != _gender)
            revert("Invalid Gender");

        borrowers[msg.sender] = Borrower(_age, _gender, _type);
        animals[_type] -= 1;
        emit Borrowed(_type); 
    }

    function giveBackAnimal()
        public
    {
        if(borrowers[msg.sender].age == 0)
            revert("No borrowed pets");

        AnimalType animal = borrowers[msg.sender].animal; 

        // Reset the value to the default value.
        delete borrowers[msg.sender];
        animals[animal] += 1;
        emit Returned(animal); 
    }

    function animalCounts(AnimalType _type)
        view 
        public
        returns (uint)
    {
        return animals[_type];
    }
}