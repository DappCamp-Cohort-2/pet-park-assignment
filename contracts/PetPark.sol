//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    address owner;

    constructor ()  {
       owner = msg.sender;
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    enum AnimalType{
        NONE,
		FISH,
		CAT,
		DOG,
		RABBIT,
		PARROT
    }

    modifier validateAnimal(AnimalType _animal) {
        require(
            _animal == AnimalType.FISH ||
            _animal == AnimalType.CAT ||
            _animal == AnimalType.DOG ||
            _animal == AnimalType.RABBIT ||
            _animal == AnimalType.PARROT
            , "Invalid animal type");
        _;
    }

    enum Gender {
        MALE, FEMALE, NONBINARY
    }

    struct Borrower {
        // Figure out if the borrower has been called
        // before using the nonce (++ for every action)
        uint nonce;

        uint age;
        Gender gender;

        // As only 1 animal might be borrowed at a
        // time let's also store this information here
        AnimalType borrowedAnimal;
    }

    mapping (AnimalType => uint) public animalCounts;
    mapping (address => Borrower) borrowers;

    event Added(AnimalType _type, uint _count);
    event Borrowed(AnimalType _type);
    event Returned(AnimalType _type);

    function add(AnimalType _type, uint _count) ownerOnly validateAnimal(_type) public {
        animalCounts[_type] = animalCounts[_type] + _count;
        emit Added(_type, _count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _type) validateAnimal(_type) public {
        require(_age > 0, "Invalid Age");

        if (borrowers[msg.sender].nonce > 0) {
            require(borrowers[msg.sender].age == _age, "Invalid Age");
            require(borrowers[msg.sender].gender == _gender, "Invalid Gender");
        }

        require(borrowers[msg.sender].borrowedAnimal == AnimalType.NONE, "Already adopted a pet");

        if (_gender == Gender.MALE) {
            require(_type == AnimalType.DOG || _type == AnimalType.FISH, "Invalid animal for men");
        }

        if (_gender == Gender.FEMALE && _age < 40) {
            require(_type != AnimalType.CAT, "Invalid animal for women under 40");
        }

        require(animalCounts[_type] > 0, "Selected animal not available");

        borrowers[msg.sender].nonce++;
        borrowers[msg.sender].age = _age;
        borrowers[msg.sender].gender = _gender;
        borrowers[msg.sender].borrowedAnimal = _type;
        animalCounts[_type]--;

        emit Borrowed(_type);
    }

    function giveBackAnimal() public {
        require(borrowers[msg.sender].borrowedAnimal != AnimalType.NONE, "No borrowed pets");

        AnimalType t = borrowers[msg.sender].borrowedAnimal;

        borrowers[msg.sender].borrowedAnimal = AnimalType.NONE;
        animalCounts[t]++;

        emit Returned(t);
    }
}