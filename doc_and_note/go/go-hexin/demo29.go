package main 

import ("fmt")

// AnimalCategory 代表动物分类学中的基本分类法。
type AnimalCategory struct {
	kingdom string
	phylum string
	class string
	order string
	family string
	genus string
	species string
}

func (ac AnimalCategory) String() string {
	return fmt.Sprintf("%s%s%s%s%s%s%s",
		ac.kingdom, ac.phylum, ac.class, ac.order,
		ac.family, ac.genus, ac.species)
}

type Animal struct {
	scientificName string 
	AnimalCategory
}

func (a Animal) String() string {
	return fmt.Sprintf("%s (category: %s)", a.scientificName, a.AnimalCategory)
}

type Cat struct{
	name string
	Animal
}

func (cat Cat) String() string {
	return fmt.Sprintf("%s (category: %s， name: %q)", cat.scientificName, cat.Animal.AnimalCategory, cat.name)
}

func main() {
	category := AnimalCategory{species:"cat"}
	fmt.Printf("the animal category: %s \n", category)

	animal := Animal{
		scientificName: "American Shorthair",
		AnimalCategory: category,
	}
	fmt.Printf("the animal: %s\n", animal)

	cat := Cat{
		name: "little pig",
		Animal: animal,
	}
	fmt.Printf("The cat: %s", cat)
}