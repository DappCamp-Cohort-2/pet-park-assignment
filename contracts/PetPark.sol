//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

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

contract PetPark {
    event Added(AnimalType indexed animalType, uint256 indexed count);
    event Borrowed(AnimalType indexed animalType);
    event Returned(AnimalType indexed animalType);

    struct Borrow {
        uint256 age;
        Gender gender;
        AnimalType animalType;
        bool isUsed;
    }

    address private _owner;
    AnimalType[] private _animals;
    mapping(address => Borrow) private _borrows;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not an owner");
        _;
    }

    function add(AnimalType animalType, uint256 count) public onlyOwner {
        // Enums seem very fragile
        require(
            animalType >= AnimalType.Fish && animalType <= AnimalType.Parrot,
            "Invalid animal"
        );
        require(count > 0, "Count must be greater than 0");

        for (uint256 i = 0; i < count; i++) {
            _animals.push(animalType);
        }

        emit Added(animalType, count);
    }

    function borrow(
        uint256 age,
        Gender gender,
        AnimalType animalType
    ) public {
        require(age > 0, "Invalid Age");
        require(
            animalType >= AnimalType.Fish && animalType <= AnimalType.Parrot,
            "Invalid animal type"
        );
        require(
            _borrows[msg.sender].isUsed == false ||
                _borrows[msg.sender].age == age,
            "Invalid Age"
        );
        require(
            _borrows[msg.sender].isUsed == false ||
                _borrows[msg.sender].gender == gender,
            "Invalid Gender"
        );
        require(
            _borrows[msg.sender].animalType == AnimalType.None,
            "Already adopted a pet"
        );
        require(
            gender == Gender.Female ||
                (animalType == AnimalType.Dog || animalType == AnimalType.Fish),
            "Invalid animal for men"
        );
        require(
            (animalType != AnimalType.Cat || age >= 40),
            "Invalid animal for women under 40"
        );

        AnimalType foundAnimalType;

        for (uint256 i = 0; i < _animals.length; i++) {
            if (_animals[i] == animalType) {
                foundAnimalType = animalType;
                delete _animals[i];
                break;
            }
        }

        require(
            foundAnimalType != AnimalType.None,
            "Selected animal not available"
        );

        _borrows[msg.sender] = Borrow({
            age: age,
            gender: gender,
            animalType: foundAnimalType,
            isUsed: true
        });
        emit Borrowed(animalType);
    }

    function giveBackAnimal() public {
        require(_borrows[msg.sender].isUsed == true, "No borrowed pets");

        AnimalType returnedAnimalType = _borrows[msg.sender].animalType;
        _animals.push(returnedAnimalType);
        delete _borrows[msg.sender];
        emit Returned(returnedAnimalType);
    }

    function animalCounts(AnimalType animalType) public view returns (uint256) {
        uint256 count = 0;

        for (uint256 i = 0; i < _animals.length; i++) {
            if (_animals[i] == animalType) {
                count++;
            }
        }

        return count;
    }
}
