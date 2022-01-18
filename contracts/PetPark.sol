//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;

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

    struct PetOwnerDetails {
        Gender gender;
        uint8 age;
        address petOwnerAddress;
        AnimalType pet;
    }

    mapping(uint8 => uint256) private shelter;
    mapping(address => PetOwnerDetails) private petOwners;

    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier onlyValidAnimalType(uint8 animalType, string memory message) {
        require(
            animalType > uint8(AnimalType.None) &&
                animalType <= uint8(AnimalType.Parrot),
            message
        );
        _;
    }

    modifier onlyValidAge(uint8 age) {
        require(age > 0, "Invalid Age");
        _;
    }

    modifier isAnimalAvailable(uint8 animalType) {
        require(shelter[animalType] > 0, "Selected animal not available");
        _;
    }

    function add(uint8 animalType, uint256 count)
        external
        isOwner
        onlyValidAnimalType(animalType, "Invalid animal")
    {
        shelter[animalType] += count;
        emit Added(AnimalType(animalType), count);
    }

    function borrow(
        uint8 age,
        uint8 gender,
        uint8 animalType
    )
        external
        onlyValidAge(age)
        onlyValidAnimalType(animalType, "Invalid animal type")
        isAnimalAvailable(animalType)
    {
        PetOwnerDetails storage petOwner = petOwners[msg.sender];

        if (petOwner.petOwnerAddress != address(0)) {
            require(petOwner.age == age, "Invalid Age");
            require(uint8(petOwner.gender) == gender, "Invalid Gender");
            revert("Already adopted a pet ");
        }

        if (isAnimalTypeInvalidForMale(gender, animalType)) {
            revert("Invalid animal for men");
        }

        if (isAnimalTypeInvalidForFemale(gender, age, animalType)) {
            revert("Invalid animal for women under 40");
        }

        petOwners[msg.sender] = PetOwnerDetails(
            Gender(gender),
            age,
            msg.sender,
            AnimalType(animalType)
        );

        shelter[animalType]--;
    
        emit Borrowed(AnimalType(animalType));
    }

    function animalCounts(uint8 animalType) external view returns (uint256) {
        return shelter[animalType];
    }

    function giveBackAnimal() external {
        PetOwnerDetails memory petOwnerDetails = petOwners[msg.sender];
        require(
            petOwnerDetails.petOwnerAddress != address(0),
            "No borrowed pets"
        );
        shelter[uint8(petOwnerDetails.pet)]++;
        delete petOwners[msg.sender];
    }

    function isAnimalTypeInvalidForMale(uint8 gender, uint8 animalType)
        private
        pure
        returns (bool)
    {
        return
            gender == uint8(Gender.Male) &&
            (animalType != uint8(AnimalType.Fish) &&
                animalType != uint8(AnimalType.Dog));
    }

    function isAnimalTypeInvalidForFemale(
        uint8 gender,
        uint8 age,
        uint8 animalType
    ) private pure returns (bool) {
        return
            gender == uint8(Gender.Female) &&
            age < 40 &&
            animalType == uint8(AnimalType.Cat);
    }
}
