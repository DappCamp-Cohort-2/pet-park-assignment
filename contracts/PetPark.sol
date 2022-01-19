//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    address private owner;

    
    
 
    enum AnimalType {
		None,
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

    event Added(AnimalType pet, uint count);
    event Borrowed(AnimalType pet); 
    event Returned(AnimalType pet);

    mapping(AnimalType => uint) animal_counts;

    mapping(address => uint) calls;
    mapping(address => AnimalType) bcalls;
    mapping(address => uint) ages;
    mapping(address => Gender) genders;

    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        animal_counts[AnimalType.None] = 0;
        animal_counts[AnimalType.Fish] = 0;
        animal_counts[AnimalType.Cat] = 0;
        animal_counts[AnimalType.Dog] = 0;
        animal_counts[AnimalType.Rabbit] = 0;
        animal_counts[AnimalType.Parrot] = 0;

    }
    
    function animalCounts(AnimalType pet) public{
        animal_counts[pet];
    }
    function add(AnimalType pet, uint count) public {
        require(    msg.sender == owner,"Not an owner");
        require(    pet != AnimalType.None,"Invalid animal" );
        animal_counts[pet] += count;

        emit Added(pet, count);

    }

    function borrow(uint age, Gender gender, AnimalType pet) public {

        require(age >0, "Invalid Age");
        require(    pet != AnimalType.None,"Invalid animal type" );
        require(animal_counts[pet]>0, "Selected animal not available");


        calls[msg.sender] += 1 ;

        //require(calls[msg.sender] == 1, "Already adopted a pet");  

        if ( calls[msg.sender] == 1 ){
            ages[msg.sender] = age;
            genders[msg.sender] = gender;
        }else {
            require(ages[msg.sender] == age, "Invalid Age");
            require(genders[msg.sender] == gender, "Invalid Gender");
        }
        require(calls[msg.sender] == 1, "Already adopted a pet");

        if( gender == Gender.Male)
          require(    pet == AnimalType.Fish || pet == AnimalType.Dog,"Invalid animal for men");
        
        if( gender == Gender.Female )
           if( pet == AnimalType.Cat )
               require( age >= 40,"Invalid animal for women under 40");
 
        
        animal_counts[pet] -= 1;
        bcalls[msg.sender] = pet;

        emit Borrowed(pet);




    }

    function giveBackAnimal() public {
        require(calls[msg.sender] > 0, "No borrowed pets");
        emit Returned(bcalls[msg.sender]);
        animal_counts[bcalls[msg.sender]] -= 1 ;
        bcalls[msg.sender] = AnimalType.None;
    }

}
