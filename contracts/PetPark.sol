// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PetPark {
    address owner;

    struct Animal {
        string Name;
        uint AnimalCount;
    }

    struct Caller {
        uint Age;
        uint Gender;
        uint AnimalType;
    }

    mapping (uint => Animal) public AnimalTypeToName;
    mapping (address => Caller) public AddressToCaller;

    constructor () {
        owner = msg.sender;
        AnimalTypeToName[1] = Animal("Fish", 0);
        AnimalTypeToName[2] = Animal("Cat", 0);
        AnimalTypeToName[3] = Animal("Dog", 0);
        AnimalTypeToName[4] = Animal("Rabbit", 0);
        AnimalTypeToName[5] = Animal("Parrot", 0);
    }

    event Added(uint AnimalType, uint AnimalCount);
    event Borrowed(uint AnimalType);

    // modifier isValidAnimal(uint _AnimalType) {
    //     if (bytes(AnimalTypeToName[_AnimalType].Name).length == 0) {
    //         revert("Invalid animal");
    //     }
    //     _;
    // }

    function animalCounts(uint _AnimalType) public view returns (uint) {
      return AnimalTypeToName[_AnimalType].AnimalCount;
    }

    function add(uint _AnimalType, uint _AnimalCount) public  {
        require(msg.sender == owner, "Not an owner");

        if (bytes(AnimalTypeToName[_AnimalType].Name).length == 0) {
            revert("Invalid animal");
        }

        AnimalTypeToName[_AnimalType].AnimalCount += _AnimalCount;
        emit Added(_AnimalType, _AnimalCount);
    }

    function borrow(uint _Age, uint _Gender, uint _AnimalType) public {

        if (_Age <= 0) {
            revert("Invalid Age");
        }

        if (bytes(AnimalTypeToName[_AnimalType].Name).length > 0 && AnimalTypeToName[_AnimalType].AnimalCount == 0) {
            revert("Selected animal not available");
        }

        if (bytes(AnimalTypeToName[_AnimalType].Name).length == 0) {
            revert("Invalid animal type");
        }





        if (AddressToCaller[msg.sender].Age > 0) {
            if (AddressToCaller[msg.sender].Age != _Age) {
                revert("Invalid Age");
            } else if (AddressToCaller[msg.sender].Gender != _Gender) {
                revert("Invalid Gender");
            } else if (AddressToCaller[msg.sender].AnimalType > 0 ){
                revert("Already adopted a pet");
            }
        }

        if (_Gender == 0) {
            if (_AnimalType != 1 && _AnimalType != 3) {
                revert("Invalid animal for men");
            }
        } else {
            if (_Age < 40 && _AnimalType == 2) {
                revert("Invalid animal for women under 40");
            }
        }

        AddressToCaller[msg.sender] = Caller(_Age, _Gender, _AnimalType);
        AnimalTypeToName[_AnimalType].AnimalCount -= 1;

        emit Borrowed(_AnimalType);
    }

    function giveBackAnimal() public {

        if (AddressToCaller[msg.sender].AnimalType == 0) {
            revert("No borrowed pets");
        } else {
            AnimalTypeToName[AddressToCaller[msg.sender].AnimalType].AnimalCount += 1;
            AddressToCaller[msg.sender].AnimalType = 0;
        }



    }




}
