//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    event Added(uint8 animal_type, uint8 count);
    event Borrowed(uint8 animal_type);
    event Returned(uint8 animal_type);
    struct Account {
        uint256 age;
        uint8 gender; // male: 0, female: 1
        bool lease;
        uint8 animal_type;
    }

    mapping(uint8 => uint256) countByAnimalType;
    mapping(uint8 => bool) validAnimalType;
    mapping(address => Account) addressByAccount;
    mapping(address => bool) addressExists;
    address owner;

    constructor() {
        owner = msg.sender;
        validAnimalType[1] = true; // fish
        validAnimalType[2] = true; // cat
        validAnimalType[3] = true; // dog
        validAnimalType[4] = true; // rabbit
        validAnimalType[5] = true; // parrot
    }

    function add(uint8 animal_type, uint8 count) public {
        require(msg.sender == owner, "Not an owner");
        if (validAnimalType[animal_type] == false) {
            revert("Invalid animal type");
        }
        countByAnimalType[animal_type] += count;
        emit Added(animal_type, count);
    }

    modifier validate_inputs(
        uint8 age,
        uint8 gender,
        uint8 animal_type
    ) {
        require(age != 0, "Invalid Age");
        require(validAnimalType[animal_type] != false, "Invalid animal type");
        require(
            countByAnimalType[animal_type] != 0,
            "Selected animal not available"
        );
        _;
    }

    function borrow(
        uint8 age,
        uint8 gender,
        uint8 animal_type
    ) public validate_inputs(age, gender, animal_type) {
        Account storage _account = addressByAccount[msg.sender];
        if (addressExists[msg.sender] == false) {
            // create a new account
            _account.age = age;
            _account.gender = gender;
            addressExists[msg.sender] = true;
        } else {
            require(_account.age == age, "Invalid Age");
            require(_account.gender == gender, "Invalid Gender");
            require(_account.lease != true, "Already adopted a pet");
        }
        if (_account.gender == 0) {
            if ((animal_type != 1) && (animal_type != 3)) {
                revert("Invalid animal for men");
            }
        } else {
            if (_account.age < 40) {
                if (animal_type == 2) {
                    revert("Invalid animal for women under 40");
                }
            }
        }
        _account.lease = true;
        _account.animal_type = animal_type;
        countByAnimalType[animal_type] -= 1;
        emit Borrowed(animal_type);
    }

    function giveBackAnimal() public {
        Account storage _account = addressByAccount[msg.sender];
        require(_account.lease != false, "No borrowed pets");
        uint8 _animal_type = _account.animal_type;
        countByAnimalType[_animal_type] += 1;
        _account.lease = false;
        _account.animal_type = 0;
        emit Returned(_animal_type);
    }

    function animalCounts(uint8 animal_type) public view returns (uint256) {
        return countByAnimalType[animal_type];
    }
}
