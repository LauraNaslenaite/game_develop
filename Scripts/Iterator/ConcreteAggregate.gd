#Implementation was based on https://www.dofactory.com/net/iterator-design-pattern
extends Aggregate
class_name ConcreteAggregate 

#creating a list
export var items = []

#initialising the list, 18- cells on a grid
func _init():
	for i in range(18):
		items.append(null)
		
#creating an iterator obj
func _create_iterator() -> Concrete_Iterator:
	var concreteIterator= Concrete_Iterator.new()
	return concreteIterator

func _get_count():
	return items.size()

func _add(index, value):
	items[index]= value

func _get_size():
	return items.size()


