//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }
    AnimalType animalType;

    enum Gender {
        Male,
        Female
    }

    struct Customer {
        Gender gender;
        uint8 age;
        AnimalType borrowedAnimal;
    }

    //mappings
    mapping(address => Customer) private borrowed;
    mapping(AnimalType => uint256) public animalCounts; 

    modifier validAnimalType(uint8 _type) {
        require(_type >= 1 && _type <= 5, "Invalid animal type");
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    //events
    event Added(uint8 _type, uint256 count);

    event Borrowed(uint8 _type);

    event Returned(uint8 _type);

    constructor() {
        owner = msg.sender;
    }

    //public functions
    function add(uint8 _type, uint256 count)
        public
        onlyOwner
        validAnimalType(_type)
    {
        animalType = AnimalType(_type);
        animalCounts[animalType] += count;

        emit Added(_type, animalCounts[animalType]);
    }

    function borrow(
        uint8 _age,
        Gender _gender,
        uint8 _type
    ) public validAnimalType(_type) {
        animalType = AnimalType(_type);
        require(_age != 0, "Invalid Age");
        require(animalCounts[animalType] != 0, "Selected animal not available");

        Customer storage currentCustomer = borrowed[msg.sender];

        if (currentCustomer.age != 0) {
            require(currentCustomer.age == _age, "Invalid Age");
            require(currentCustomer.gender == _gender, "Invalid Gender");
        }

        require(
            currentCustomer.borrowedAnimal == AnimalType.None,
            "Already adopted a pet"
        );

        if (_gender == Gender.Male)
            require(
                animalType != AnimalType.Dog && animalType == AnimalType.Fish,
                "Invalid animal for men"
            );

        if (_gender == Gender.Female && _age < 40)
            require(
                animalType != AnimalType.Cat,
                "Invalid animal for women under 40"
            );

        //Assign age and gender if this is the first time this address is calling
        if (currentCustomer.age == 0) {
            currentCustomer.age = _age;
            currentCustomer.gender = _gender;
        }

        currentCustomer.borrowedAnimal = animalType;
        animalCounts[animalType] -= 1;

        emit Borrowed(_type);
    }

    function giveBackAnimal() public {
        Customer storage currentCustomer = borrowed[msg.sender];

        require(
            currentCustomer.borrowedAnimal != AnimalType.None,
            "No borrowed pets"
        );

        currentCustomer.borrowedAnimal = AnimalType.None;
        animalCounts[animalType] += 1;

        emit Returned(uint8(currentCustomer.borrowedAnimal));
    }

    function getCount(uint8 _type)
        public
        view
        validAnimalType(_type)
        returns (uint256 _count)
    {
        _count = animalCounts[AnimalType(_type - 1)];
    }
}
