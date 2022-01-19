//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// TODO: I would import differnetly if prod
import "./open-zeplin/ownable.sol";

contract PetPark is Ownable {
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
    event Added(AnimalType animalType, uint256 count);

    struct Animal {
        uint256 count;
        AnimalType animalType;
    }

    mapping(address => AnimalType) public borrowerAddressToAnimalType;

    Animal[] animals;

    constructor() {}

    function add(AnimalType _animalType, uint256 _count) public onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");

        animals.push(Animal({count: _count, animalType: _animalType}));

        emit Added(_animalType, _count);
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        AnimalType _animalType
    ) public {
        require(_age > 0, "Invalid Age");
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(
            borrowerAddressToAnimalType[msg.sender] == AnimalType.None,
            "Already adopted a pet"
        );

        int256 _foundAnimalIndex = -1;
        AnimalType _foundAnimalType;

        if (_gender == Gender.Male) {
            require(
                _animalType == AnimalType.Dog || _animalType == AnimalType.Fish,
                "Invalid animal for men"
            );
        }

        if (_gender == Gender.Female && _age < 40) {
            require(
                _animalType != AnimalType.Cat,
                "Invalid animal for women under 40"
            );
        }

        // TODO: There will be issues here if there are duplicates of animal type
        // ignoring for now
        for (uint256 i = 0; i < animals.length; i++) {
            if (animals[i].animalType == _animalType) {
                // TODO: fix this mapping to be better
                // _foundAnimalIndex = int256(i);
                _foundAnimalType = _animalType;
            }
        }

        // require(_foundAnimalIndex > -1, "Selected animal not available");
        require(
            _foundAnimalType != AnimalType.None,
            "Selected animal not available"
        );

        // TODO: issue where animal could be borrowed multiple times
        // borrowerAddressToAnimalType[msg.sender] = _foundAnimalIndex;
        borrowerAddressToAnimalType[msg.sender] = _foundAnimalType;
    }
}
