//SPDX-License-Identifier: Unlicense
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract PetPark {

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

	struct Borrower {
		uint256 age;
		Gender gender;
		AnimalType animal_type;
	}

	struct Animal {
		uint256 id;
		AnimalType animal_type;
	}

	// events
	event Added(AnimalType, uint256);

	event Borrowed(AnimalType);

	event Returned(AnimalType);

	// members
	address private m_owner;

	mapping(address => Borrower) m_borrower_attributes;

	uint256 private m_animal_id = 0;
	mapping(uint256 => Animal) private m_id_to_animal;
	mapping(AnimalType => uint256) private m_animal_to_count;
	mapping(AnimalType => uint256) private m_animal_to_borrowed_count;

	constructor() {
		m_owner = msg.sender;
	}

	modifier isValidAge(uint256 _borrower_age) {
		require(_borrower_age > 0, "Invalid Age");
		_;
	}

	modifier isValidGender(uint256 _borrower_gender_num) {
		require(_borrower_gender_num >= 0, "Invalid Gender");
		require(
			_borrower_gender_num <= uint256(Gender.Female),
			"Invalid Gender"
		);
		_;
	}

	modifier isValidAnimalType(uint256 _animal_type_num) {
		require(_animal_type_num > 0, "Invalid animal type");
		require(
			_animal_type_num <= uint256(AnimalType.Parrot),
			"Invalid animal type"
		);
		_;
	}

	function add(uint256 _animal_type_num, uint256 _animal_type_count)
		external
		isValidAnimalType(_animal_type_num)
	{
		require(msg.sender == m_owner, "Not an owner");

		// update count for this animal type
		AnimalType animal_type = AnimalType(_animal_type_num);
		m_animal_to_count[animal_type] = m_animal_to_count[animal_type] + _animal_type_count;

		// update total count of animals
		m_animal_id += _animal_type_count;

		// emit added event
		emit Added(animal_type, _animal_type_count);
	}

	function borrow(
		uint256 _borrower_age,
		uint256 _borrower_gender_num,
		uint256 _animal_type_num
	)
		public
		isValidAge(_borrower_age)
		isValidGender(_borrower_gender_num)
		isValidAnimalType(_animal_type_num)
	{
		Gender _borrower_gender = Gender(_borrower_gender_num);
		AnimalType animal_type = AnimalType(_animal_type_num);

		// check if borrower exists
		bool borrower_exists = m_borrower_attributes[msg.sender].age > 0;
		if (borrower_exists) {
			// -> check that attributes are consistent
			require(
				m_borrower_attributes[msg.sender].age == _borrower_age,
				"Invalid Age"
			);
			require(
				m_borrower_attributes[msg.sender].gender == _borrower_gender,
				"Invalid Gender"
			);

			// -> check that borrower has no borrowed animal in custody
			require(
				m_borrower_attributes[msg.sender].animal_type ==
					AnimalType.None,
				"Already adopted a pet"
			);
		}

		// check what men are allowed to borrow
		if (_borrower_gender == Gender.Male) {
			require(
				animal_type == AnimalType.Dog || animal_type == AnimalType.Fish,
				"Invalid animal for men"
			);
		} else {
			// check what women are allowed to borrow
			require(_borrower_gender == Gender.Female);
			if (_borrower_age < 40) {
				require(
					animal_type != AnimalType.Cat,
					"Invalid animal for women under 40"
				);
			}
		}

		// check if animal available to borrow
		uint256 animals_type_total = m_animal_to_count[animal_type];
		uint256 animals_type_borrowed = m_animal_to_borrowed_count[animal_type];
		uint256 animals_available_to_borrow = animals_type_total -
			animals_type_borrowed;

		assert(animals_available_to_borrow >= 0);
		if (animals_available_to_borrow == 0) {
			revert("Selected animal not available");
		}

		if (!borrower_exists) {
			// first-time borrower -> add attribute
			m_borrower_attributes[msg.sender] = Borrower({
				age: _borrower_age,
				gender: _borrower_gender,
				animal_type: animal_type
			});
		} else {
			// pre-existing borrower
			// -> if we get here, pre-existing borrower passes all checks
			// ->  give the borrower this animal
			m_borrower_attributes[msg.sender].animal_type = animal_type;
		}

		// if we get here, borrow action complete
		// -> update borrowed count
		m_animal_to_borrowed_count[animal_type]++;
		// -> emit event
		emit Borrowed(animal_type);
	}

	function giveBackAnimal() public {
		require(m_borrower_attributes[msg.sender].age > 0, "No borrowed pets");
		require(
			m_borrower_attributes[msg.sender].animal_type != AnimalType.None,
			"No borrowed pets"
		);

		// nullify the animal entry for this borrower
		AnimalType borrowed_animal_type = m_borrower_attributes[msg.sender]
			.animal_type;
		m_borrower_attributes[msg.sender].animal_type = AnimalType.None;

		// update the borrowed count
		m_animal_to_borrowed_count[borrowed_animal_type]--;

		// emit event
		emit Returned(borrowed_animal_type);
	}

	function animalCounts(uint256 _animal_type_num)
		external
		view
		isValidAnimalType(_animal_type_num)
		returns (uint256)
	{
		AnimalType animal_type = AnimalType(_animal_type_num);
		return
			m_animal_to_count[animal_type] -
			m_animal_to_borrowed_count[animal_type];
	}
}
