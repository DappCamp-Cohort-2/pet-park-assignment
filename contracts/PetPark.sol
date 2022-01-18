//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    enum AnimalType {
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

    struct Identity {
        Gender gender;
        uint age;
    }

    address owner;
    mapping(AnimalType => uint) public animalCounts;
    mapping(address => AnimalType) public loanedAnimals;
    mapping(address => Identity) public identities;

    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint _count) public onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType) public {
        require(_age > 0, "Invalid Age");
        if (_gender == Gender.Female && _age < 40) {
            require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }
        Identity memory identity = identities[msg.sender];
        if (identity.age != 0) {
            require(identity.gender == _gender, "Invalid Gender");
            require(identity.age == _age, "Invalid Age");
        }
        require(identity.gender == _gender, "Invalid Age");
        require(identity.gender == _gender, "Invalid Age");
        require(_animalType != AnimalType.None, "Invalid animal type");
        uint inventory = animalCounts[_animalType];
        require(inventory > 0, "Selected animal not available");
        AnimalType alreadyBorrowed = loanedAnimals[msg.sender];
        require(alreadyBorrowed == AnimalType.None, "Already adopted a pet");
        if (_gender == Gender.Male) {
            // Men can only borrow dog and fish
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        }
        animalCounts[_animalType] = animalCounts[_animalType] - 1;
        loanedAnimals[msg.sender] = _animalType;
        identities[msg.sender] = Identity(_gender, _age);
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        AnimalType loanedAnimal = loanedAnimals[msg.sender];
        require(loanedAnimal != AnimalType.None, "No borrowed pets");
        loanedAnimals[msg.sender] = AnimalType.None;
        animalCounts[loanedAnimal] += 1;
    }
}