//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Ownable {
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
}

contract PetPark is Ownable {
    enum Animal {
        none,
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

    struct User {
        uint256 age;
        Gender gender;
        Animal borrowingAnimal;
    }

    event Added(Animal _animal, uint256 _count);
    event Borrowed(Animal _animal);
    event Returned(Animal _animal);

    mapping(Animal => uint256) public animalCounts;
    mapping(address => User) private users;

    modifier validAnimal(Animal _animal, string memory errorMessage) {
        require(_animal != Animal.none, errorMessage);
        _;
    }

    function add(Animal _animal, uint256 _count)
        external
        onlyOwner
        validAnimal(_animal, "Invalid animal")
    {
        animalCounts[_animal] += _count;
        emit Added(_animal, _count);
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        Animal _animal
    ) external validAnimal(_animal, "Invalid animal type") {
        require(_age > 0, "Invalid Age");

        User memory recordedUser = users[msg.sender];
        if (recordedUser.age == 0) {
            users[msg.sender] = User(_age, _gender, Animal.none);
        } else {
            require(recordedUser.age == _age, "Invalid Age");
            require(recordedUser.gender == _gender, "Invalid Gender");
        }

        require(
            recordedUser.borrowingAnimal == Animal.none,
            "Already adopted a pet"
        );

        if (_gender == Gender.Male) {
            require(
                _animal == Animal.Dog || _animal == Animal.Fish,
                "Invalid animal for men"
            );
        } else if (_gender == Gender.Female) {
            require(
                !(_age < 40 && _animal == Animal.Cat),
                "Invalid animal for women under 40"
            );
        }

        require(animalCounts[_animal] > 0, "Selected animal not available");
        animalCounts[_animal]--;
        users[msg.sender].borrowingAnimal = _animal;

        emit Borrowed(_animal);
    }

    function giveBackAnimal() external {
        Animal borrowed = users[msg.sender].borrowingAnimal;
        require(borrowed != Animal.none, "No borrowed pets");

        users[msg.sender].borrowingAnimal = Animal.none;
        animalCounts[borrowed]++;

        emit Returned(borrowed);
    }
}
