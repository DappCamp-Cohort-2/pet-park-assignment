//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    enum Animal{None, Fish, Cat, Dog, Rabbit, Parrot}
    enum Gender {Male, Female}
    address private owner;
    mapping(Animal => uint) private animap; 
 
    struct Person {
        uint age;
        Gender gender;
        Animal animal;
    }

    mapping(address => Person) private bmap; 



    event Added(Animal animal, uint count);
    event Borrowed(Animal animal);


    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }

    modifier ownerCheck() {
        require(msg.sender == owner, "Not an owner");
        _;    
    }

    function add(Animal animal, uint count) public ownerCheck {

        require(animal >= Animal.Fish && animal <= Animal.Parrot, "Invalid animal");
        animap[animal] = animap[animal] + count;
        emit Added(animal, count);
    }  

    function borrow(uint8 age, Gender gender, Animal animal) public {
        Person storage person; 
        uint animalCount;

        require(age != 0, "Invalid Age");
        require(animal >= Animal.Fish && animal <= Animal.Parrot, "Invalid animal type");

        animalCount = animap[animal];
        require(animalCount > 0, "Selected animal not available");

        person = bmap[msg.sender];
        if (person.age != 0) {
            require (person.age == age, "Invalid Age");
            require (person.gender == gender, "Invalid Gender");
            require (person.animal == Animal.None, "Already adopted a pet");
        }   

        if (gender == Gender.Male) { 
            require(animal == Animal.Dog || animal == Animal.Fish, "Invalid animal for men"); 
        } else {
            if (age < 40) {
                require(animal != Animal.Cat, "Invalid animal for women under 40");     
            }
        }


        animap[animal] = animap[animal] - 1;
        person.age = age;
        person.gender = gender;
        person.animal = animal;
        bmap[msg.sender] = person;

        emit Borrowed(animal);
    }

    function animalCounts(Animal animal) public view returns (uint) {
        return animap[animal];
    }

    function giveBackAnimal() public {
        Person memory person; 
        person = bmap[msg.sender]; 

        require (person.animal != Animal.None, "No borrowed pets");
        animap[person.animal] = animap[person.animal] + 1;
        bmap[msg.sender].animal = Animal.None;
    }

}