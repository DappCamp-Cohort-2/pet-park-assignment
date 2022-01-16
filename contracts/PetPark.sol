//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }
    enum Gender { Male, Female }

    struct BorrowerInfo {
        Gender gender;
        uint age;
        AnimalType borrowing;
    }

    address owner;
    mapping (address => BorrowerInfo) borrowerInfo;

    mapping(AnimalType => uint) public animalCounts;
    event Added(AnimalType _type, uint _count);
    event Borrowed(AnimalType _type);
    event Returned(AnimalType _type);

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _type, uint _count) public {
        require(msg.sender == owner, "Not an owner");
        require(_type != AnimalType.None, "Invalid animal");
        animalCounts[_type] += _count;
        emit Added(_type, _count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _type) public {
        if (borrowerInfo[msg.sender].age != 0) {
            require(borrowerInfo[msg.sender].gender == _gender, "Invalid Gender");
            require(borrowerInfo[msg.sender].age == _age, "Invalid Age");
            require(borrowerInfo[msg.sender].borrowing == AnimalType.None, "Already adopted a pet");
        } else {
            require(_age != 0, "Invalid Age");
            borrowerInfo[msg.sender] = BorrowerInfo(_gender, _age, AnimalType.None);
        }

        require(_type != AnimalType.None, "Invalid animal type");
        require(animalCounts[_type] > 0, "Selected animal not available");

        if (_gender == Gender.Male) {
            require(_type == AnimalType.Fish || _type == AnimalType.Dog, "Invalid animal for men");
        } else if (_age < 40) {
            require(_type != AnimalType.Cat, "Invalid animal for women under 40");
        }

        borrowerInfo[msg.sender].borrowing = _type;
        animalCounts[_type]--;
        emit Borrowed(_type);
    }

    function giveBackAnimal() public {
        require(borrowerInfo[msg.sender].borrowing != AnimalType.None, "No borrowed pets");
        AnimalType _type = borrowerInfo[msg.sender].borrowing;

        animalCounts[_type]++;
        borrowerInfo[msg.sender].borrowing = AnimalType.None;
        emit Returned(_type);
    }
}
