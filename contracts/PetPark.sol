//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    address owner;
    mapping (uint8 => uint) public animalCounts;
    mapping (address => bool) hasBorrowed;
    mapping (address => uint8) ages;
    mapping (address => uint8) genders;
    mapping (address => bool) everBorrowed;
    mapping (address => uint8) animaltypeBorrowed;

    event Added(uint8 animaltype, uint8 count);
    event Borrowed(uint8 animaltype);
    event Returned(uint8 animaltype);

    constructor() {
        owner = msg.sender;
    }

    modifier ownercheck() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    function add(uint8 animaltype, uint8 count) public ownercheck {
        require(0 < animaltype && animaltype <= 5, "Invalid animal");
        animalCounts[animaltype] = animalCounts[animaltype] + count;
        emit Added(animaltype, count);
    }

    
    function borrow(uint8 age, uint8 gender, uint8 animaltype) public {
        require(gender <= 1, "Invalid Gender");
        require(age > 0, "Invalid Age" );
        require(0 < animaltype && animaltype <= 5, "Invalid animal type");
        require(animalCounts[animaltype] >= 1, "Selected animal not available");

        if (!everBorrowed[msg.sender]) {
            everBorrowed[msg.sender] = true;
            ages[msg.sender] = age;
            genders[msg.sender] = gender;
        }

        // if msg.sender is Man, he can only borrow animal 1 and 3.
        // if msg.sender is Woman and age >= 40, then borrow anything.
        // if Woman and age < 40, then she can borrow anything except animal 2.
        require(ages[msg.sender] == age,"Invalid Age");
        require(gender == genders[msg.sender], "Invalid Gender");
        require(hasBorrowed[msg.sender] == false, "Already adopted a pet");

        if (gender == 0) {
            require(animaltype == 1 || animaltype == 3, "Invalid animal for men");
        } else if (gender == 1 && age < 40) {
            require(animaltype != 2, "Invalid animal for women under 40");
        }
        
        hasBorrowed[msg.sender] = true;
        animalCounts[animaltype]--;
        animaltypeBorrowed[msg.sender] = animaltype;

        emit Borrowed(animaltype);

    }

    function giveBackAnimal() public {
      require(hasBorrowed[msg.sender] == true, "No borrowed pets");

      uint8 _animaltype = animaltypeBorrowed[msg.sender];
      animalCounts[_animaltype]++;
      hasBorrowed[msg.sender] == false;

      emit Returned(_animaltype);
    }

}

