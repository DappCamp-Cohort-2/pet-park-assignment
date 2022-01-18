//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    struct Borrower {
        uint gender;
        uint age;
        bool borrowed;
        uint currentAnimal;
    }

    // AnimalTypes are Fish (1), Cat (2), Dog (3), Rabbit (4), Parrot (5)
    mapping (uint => uint) animalsInPark;
    mapping (address => Borrower) borrowers;
    address public owner;

    event Added(uint indexed AnimalType, uint AnimalCount);
    event Borrowed(uint indexed AnimalType);
    event Returned(uint indexed AnimalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function add(uint _animalType, uint _count) public onlyOwner {
        require((_animalType < 6) && (_animalType !=0), "No animals of that type allowed!");
        animalsInPark[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, uint _gender, uint _animalType) public {
        require((_animalType < 6) && (_animalType != 0), "No animals of that type known!");
        
        // Gender Male (0), Female (1)
        if (_gender == 0) {
            require((_animalType == 1) || (_animalType == 3), "Men can only borrow a dog or a fish!");
        } else if (_age < 40) {
            require((_animalType != 2), "Women under 40 cannot borrow a cat!");
        }

        Borrower storage b = borrowers[msg.sender];
        if (b.borrowed) {
            require((b.age == _age) && (b.gender == _gender), "You're lying about age or gender!");
        }
        require((b.currentAnimal != _animalType), "You already have this animal borrowed!")
        require((animalsInPark[_animalType] > 0), "No animal of that type available to borrow sorry!");
        
        if (b.currentAnimal != 0) {
            // give back an animal to borrow a new one
            giveBackAnimal();
        }

        animalsInPark[_animalType] -= 1;
        b.currentAnimal = _animalType;

        if (!b.borrowed) {
            b.age = _age;
            b.gender = _gender;
            b.borrowed = true;
        }
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        Borrower storage b = borrowers[msg.sender];
        require(b.borrowed, "You've never borrowed!");
        animalsInPark[b.currentAnimal] += 1;
        uint returnedAnimal = b.currentAnimal;
        b.currentAnimal = 0;
        emit Returned(returnedAnimal);
    }

}
