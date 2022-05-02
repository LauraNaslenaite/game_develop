#Implementation was based on https://www.dofactory.com/net/iterator-design-pattern
extends Iterator
class_name Concrete_Iterator

#getting a ConcreteAggregate obj
var load_class=load("res://Scripts/Iterator/ConcreteAggregate.gd")
var aggregate = load_class.new()
var current = 0

#iterating through the list
func _get_next():
	var temp = null
	if current < aggregate.items.size() - 1:
		current +=1
		temp = aggregate.items[current]
	return temp

#getting current item in a list
func _get_current():
	return aggregate.items[current]

#deleting an item based on value
func erase_by_value(value):
	aggregate.items.erase(value)

func _is_done():
	return current >= aggregate.items._get_count()
