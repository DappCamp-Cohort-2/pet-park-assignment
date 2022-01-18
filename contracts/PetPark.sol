//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    
    address owner;
    mapping(uint => string) public animal;
    mapping(uint => string) public gender;

    /*
    struct Borrower {
        uint age;
        uint gender;
        uint animaltype;
    }
    */
    
    /*
    mapping(address => bool) public isborrowing;
    mapping(address => Borrower) public borrowerinfo;
    mapping(address => uint) public borrowerindex;
    */

    uint[5] public pets;   // an array of counts of animals
    //Borrower[] public borrowers;   // an array of borrowers 

    constructor () {
        owner = msg.sender;
    }

    event Added(string animaltype, uint count);
    /*event AddedAnimal(string animaltype, uint count);
    event Borrowed(string animaltype);
    event Returned(string animaltype);
    */

    // For the owner to add the count of an animal
    function add(uint _animaltype, uint _count) public {
        require(msg.sender == owner);
        require(_animaltype >= 1 && _animaltype <=5);
        pets[_animaltype-1] += _count;
        emit Added(animal[_animaltype], _count);
    }  
    /*
    //In case the owner wants to add another type of animal which 
    //is not listed in the pet list,
    //the owner can utilize the following function:
    function addanimal(string memory _animal, uint _count) external {
        require(msg.sender == owner);
        pets.push(_count);
        animal[pets.length] = _animal; 
        emit AddedAnimal(animal[pets.length], _count);
    }

    function borrow(uint _age, uint _gender, uint _animaltype) external {
        require(isborrowing[msg.sender] == false, "You need to return a pet before borrowing a new pet.");
        if (_gender == 0) require(_animaltype == 1 || _animaltype == 3, "Men are allowed to borrow only fish or dog.");
        else require(_age >= 40 || (_age < 40 && _animaltype != 2), "Women under 40 are not allowed to borrow cat.");  
        borrowers.push(Borrower(_age, _gender, _animaltype));
        isborrowing[msg.sender] = true;
        borrowerindex[msg.sender] = borrowers.length;
        emit Borrowed(animal[_animaltype]);
    }

    function giveBackAnimal() external {
        require(isborrowing[msg.sender] == true, "You haven't borrowed any pet.");
        delete borrowers[borrowerindex[msg.sender]-1];
        emit Returned(animal[borrowerinfo[msg.sender].animaltype]);
    }
    */
}