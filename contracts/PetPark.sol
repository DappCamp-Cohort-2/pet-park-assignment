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

    constructor() public {
        owner = msg.sender;
    }

    function add(uint _type, uint _count) public onlyOwner {
        require(_type > 0 && _type <= 5, "Invalid animal");
        park[_type] = park[_type] + _count;
        emit Added(_type, _count);
    }

    function borrow(uint _age, uint _gender, uint _type) public notBorrowing {
        require(park[_type] > 0, "No pets of that type are in the park!");
        if(historicalBorrowers[msg.sender].age == 0 && historicalBorrowers[msg.sender].gender == 0) {
            historicalBorrowers[msg.sender] = Borrower(_age, _gender);
        }
        // Checks to make sure that the current address has not borrowed before with different age/gender
        require(checkHistoricalBorrowers(msg.sender, _age, _gender), "You've already borrowed with different details");

        // Validate age and gender data
        if(_gender == 0) {
            require(_type == 1 || _type == 3, "Men can only borrow dogs or fish");
        }
        else if(_age < 40) {
            require(_type != 2, "Women under 40 cannot borrow cats");
        }
        
        park[_type] = park[_type] - 1;
        currentBorrowers[msg.sender] = true;
        emit Borrowed(_type);
    }

    function giveBackAnimal(uint _type) public {
        require(currentBorrowers[msg.sender], "You need to borrow first!");

        park[_type] = park[_type] + 1;
        currentBorrowers[msg.sender] = false;
        emit Returned(_type);
    }

    function checkHistoricalBorrowers(address a, uint age, uint gender) private view returns(bool) {
        if(historicalBorrowers[a].age != age || historicalBorrowers[a].gender != gender) {
            return false;
        }
        return true;
    }

    function animalCounts(uint _type) public view returns(uint) {
        return park[_type];
    }

    modifier onlyOwner {
         require(msg.sender == owner);
         _;
    }

    modifier notBorrowing {
        require(!currentBorrowers[msg.sender], "You are already borrowing a pet!");
        _;
    }
}