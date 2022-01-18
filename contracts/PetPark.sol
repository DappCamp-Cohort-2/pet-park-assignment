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
    struct BorrowerProfile {
        uint256 age;
        Gender gender;
        AnimalType borrowedAnimal;
    }
    address owner;
    mapping(AnimalType => uint256) animalsInShelter;
    mapping(address => BorrowerProfile) borrowerProfiles;

    event Added(AnimalType indexed _animalType, uint256 count);
    event Borrowed(AnimalType indexed _animalType);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier onlyValidAnimal(AnimalType _animalType) {
        require(_animalType != AnimalType.None, "Invalid animal type");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint256 _count)
        external
        onlyOwner
        onlyValidAnimal(_animalType)
    {
        require(_animalType != AnimalType.None, "Invalid animal type");
        animalsInShelter[_animalType] = _count;
        emit Added(_animalType, _count);
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        AnimalType _animalType
    ) external onlyValidAnimal(_animalType) {
        require(_age > 0, "Invalid Age");
        if (borrowerProfiles[msg.sender].age != 0) {
            require(borrowerProfiles[msg.sender].age == _age, "Invalid Age");
            require(
                borrowerProfiles[msg.sender].gender == _gender,
                "Invalid Gender"
            );
        }
        require(
            borrowerProfiles[msg.sender].borrowedAnimal == AnimalType.None,
            "Already adopted a pet"
        );
        require(
            animalsInShelter[_animalType] > 0,
            "Selected animal not available"
        );
        require(animalsInShelter[_animalType] > 0, "Animal not available");

        if (_gender == Gender.Male) {
            require(
                _animalType == AnimalType.Dog || _animalType == AnimalType.Fish,
                "Invalid animal for men"
            );
        } else {
            if (_age < 40) {
                require(
                    _animalType != AnimalType.Cat,
                    "Invalid animal for women under 40"
                );
            }
        }

        animalsInShelter[_animalType] -= 1;
        borrowerProfiles[msg.sender] = BorrowerProfile({
            age: _age,
            gender: _gender,
            borrowedAnimal: _animalType
        });

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        require(
            borrowerProfiles[msg.sender].borrowedAnimal != AnimalType.None,
            "No borrowed pets"
        );

        animalsInShelter[borrowerProfiles[msg.sender].borrowedAnimal] += 1;
        borrowerProfiles[msg.sender].borrowedAnimal = AnimalType.None;
    }

    function animalCounts(AnimalType _animalType)
        external
        view
        returns (uint256)
    {
        return animalsInShelter[_animalType];
    }
}
