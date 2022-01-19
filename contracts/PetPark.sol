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
    event Borrowed(AnimalType animalType);

    struct Animal {
        uint256 count;
        AnimalType animalType;
    }
    struct Person {
        uint256 age;
        Gender gender;
    }

    mapping(address => AnimalType) public borrowerAddressToAnimalType;
    mapping(AnimalType => uint256) public AnimalTypeCount;
    mapping(address => Person) public AddressToPerson;

    function add(AnimalType _animalType, uint256 _count) public onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");

        AnimalTypeCount[_animalType] += _count;

        emit Added(_animalType, _count);
    }

    modifier isSamePerson(uint256 _age, Gender _gender) {
        // TODO: Check if person already set better
        if (AddressToPerson[msg.sender].age > 0) {
            require(
                AddressToPerson[msg.sender].gender == _gender,
                "Invalid Gender"
            );
            require(AddressToPerson[msg.sender].age == _age, "Invalid Age");
        }
        _;
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        AnimalType _animalType
    ) public isSamePerson(_age, _gender) {
        require(_age > 0, "Invalid Age");
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(
            borrowerAddressToAnimalType[msg.sender] == AnimalType.None,
            "Already adopted a pet"
        );

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

        require(
            AnimalTypeCount[_animalType] > 0,
            "Selected animal not available"
        );

        borrowerAddressToAnimalType[msg.sender] = _animalType;
        AnimalTypeCount[_animalType] -= 1;
        AddressToPerson[msg.sender] = Person({age: _age, gender: _gender});
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(
            borrowerAddressToAnimalType[msg.sender] != AnimalType.None,
            "No borrowed pets"
        );

        AnimalTypeCount[borrowerAddressToAnimalType[msg.sender]] += 1;
    }

    function animalCounts(AnimalType _animalType)
        public
        view
        returns (uint256)
    {
        return AnimalTypeCount[_animalType];
    }
}
