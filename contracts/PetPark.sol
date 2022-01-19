//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address private owner;
    struct BorrowerInfo {
        uint age;
        uint gender;
        uint animalBorrowed;
    }
    mapping (uint => uint) private animalCountMapping;
    mapping (address => BorrowerInfo) private borrowerInfo;

    event Added(uint _animalType, uint _count);
    event Borrowed(uint _animalType);
    event Returned(uint _animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    function animalCounts(uint _animalType) public view returns (uint) {
        return animalCountMapping[_animalType];
    }

    function add(uint _animalType, uint _count) public onlyOwner {
        require(_animalType > 0 && _animalType <= 5, "Invalid animal");
        animalCountMapping[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, uint _gender, uint _animalType) public {
        require(_age > 0, "Invalid Age");
        if (borrowerInfo[msg.sender].age == 0) {
            borrowerInfo[msg.sender] = BorrowerInfo(_age, _gender, 0);
        } else {
            require(_age == borrowerInfo[msg.sender].age, "Invalid Age");
            require(_gender == borrowerInfo[msg.sender].gender, "Invalid Gender");
        }
        require(_animalType > 0 && _animalType <= 5, "Invalid animal type");
        require(animalCountMapping[_animalType] > 0, "Selected animal not available");
        require(borrowerInfo[msg.sender].animalBorrowed == 0, "Already adopted a pet");
        if (_gender == 0) {
            require(_animalType == 1 || _animalType == 3, "Invalid animal for men");
        }
        if (_gender == 1 && _age < 40) {
            require(_animalType != 2, "Invalid animal for women under 40");
        }
        borrowerInfo[msg.sender].animalBorrowed = _animalType;
        animalCountMapping[_animalType] -= 1;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        uint _animalBorrowed = borrowerInfo[msg.sender].animalBorrowed;
        require(_animalBorrowed > 0, "No borrowed pets");
        borrowerInfo[msg.sender].animalBorrowed = 0;
        animalCountMapping[_animalBorrowed] += 1;
        emit Returned(_animalBorrowed);
    }
}
