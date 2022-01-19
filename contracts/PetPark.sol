//SPDX-License-Identifier: MIT
pragma solidity >0.4.0 <=0.9.0;


contract PetPark {
    address owner;
    // Park mapping access pattern: park[type] = count;
    mapping(uint => uint) private park;
    mapping(address => bool) private currentBorrowers;
    mapping(address => Borrower) private historicalBorrowers;

    struct Borrower {
        uint age;
        uint gender;
    }

    event Added(uint AnimalType, uint Count);
    event Borrowed(uint AnimalType);
    event Returned(uint AnimalType);

    constructor() {
        owner = msg.sender;
    }

    function add(uint _type, uint _count) public validType(_type) onlyOwner {
        park[_type] = park[_type] + _count;
        emit Added(_type, _count);
    }

    function borrow(uint _age, uint _gender, uint _type) public notBorrowing validType(_type) {
        require(_age > 0, "Invalid Age");
        require(park[_type] > 0, "Selected animal not available");
        if(historicalBorrowers[msg.sender].age == 0 && historicalBorrowers[msg.sender].gender == 0) {
            historicalBorrowers[msg.sender] = Borrower(_age, _gender);
        }
        // Checks to make sure that the current address has not borrowed before with different age/gender
        checkHistoricalBorrowers(msg.sender, _age, _gender);

        // Validate age and gender data
        if(_gender == 0) {
            require(_type == 1 || _type == 3, "Invalid animal for men");
        }
        else if(_age < 40) {
            require(_type != 2, "Invalid animal for women under 40");
        }
        park[_type] = park[_type] - 1;
        currentBorrowers[msg.sender] = true;
        emit Borrowed(_type);
    }


    function giveBackAnimal(uint _type) public {
        require(currentBorrowers[msg.sender], "No borrowed pets");

        park[_type] = park[_type] + 1;
        currentBorrowers[msg.sender] = false;
        emit Returned(_type);
    }

    function checkHistoricalBorrowers(address a, uint age, uint gender) private view {
        if(historicalBorrowers[a].age != 0) {
            require(historicalBorrowers[a].age == age, "Invalid Age");
            require(historicalBorrowers[a].gender == gender, "Invalid Gender");
        }
    }

    function animalCounts(uint _type) public view returns(uint) {
        return park[_type];
    }

    modifier onlyOwner {
         require(msg.sender == owner, "Not an owner");
         _;
    }

    modifier notBorrowing {
        require(!currentBorrowers[msg.sender], "Already adopted a pet");
        _;
    }

    modifier validType(uint _type) {
        require(_type > 0 && _type <= 5, "Invalid animal");
        _;
    }
}