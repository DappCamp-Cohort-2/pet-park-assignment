//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }
    enum Gender { Male, Female }
    struct Person {
        Gender gender;
        uint8 age;
        AnimalType animal;
    }

    mapping(AnimalType => uint) petsInThePark;
    mapping(address => Person) personThatBorrowed;
 
    address owner;
    event Added(AnimalType indexed animal, uint count);
    event Borrowed(AnimalType indexed animal);
    event Returned(AnimalType indexed animal);
    modifier isOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }
    modifier acceptedAnimal(AnimalType _animal) {
        require(_animal > AnimalType.None, "Invalid animal");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animal, uint _count) external isOwner acceptedAnimal(_animal){
        petsInThePark[_animal] = _count;
        emit Added(_animal, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animal) external  {
        require(_age > 0, "Invalid Age");
        require(_animal != AnimalType.None, "Invalid animal type");
        require(petsInThePark[_animal] > 0, "Selected animal not available");
        
        require(personThatBorrowed[msg.sender].animal == AnimalType.None, "Already adopted a pet");

        if(petsInThePark[personThatBorrowed[msg.sender].animal] != 0){
            require(personThatBorrowed[msg.sender].age == _age, "Invalid Age");
            require(personThatBorrowed[msg.sender].gender == _gender, "Invalid Gender");
        }

        if (_gender == Gender.Male) {
                require(_animal == AnimalType.Fish || _animal == AnimalType.Dog, "Invalid animal for men");
            } else {
                if (_age < 40) {
                require(_animal != AnimalType.Cat, "Invalid animal for women under 40");
                }
            } 

        
        personThatBorrowed[msg.sender].animal = _animal;
        petsInThePark[_animal] -= 1;
        emit Borrowed(_animal);
    }
    function giveBackAnimal() external {
        require(personThatBorrowed[msg.sender].animal != AnimalType.None, "No borrowed pets");

        petsInThePark[personThatBorrowed[msg.sender].animal] += 1;
        
        personThatBorrowed[msg.sender].animal = AnimalType.None;
        emit Returned(personThatBorrowed[msg.sender].animal);
    }

    

    function animalCounts(AnimalType _animal) external view returns(uint) {
        return  petsInThePark[_animal];
    }

}