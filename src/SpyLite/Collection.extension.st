Extension { #name : #Collection }

{ #category : #'*SpyLite' }
Collection >> asOrderedSet [
	"Answer a Set whose elements are the unique elements of the receiver."

	^ OrderedSet withAll: self
]

{ #category : #'*SpyLite' }
Collection >> orderedUnion: aCollection [
	"Answer the set theoretic union of two collections."
	"(#(1 2 3) union: #(4 5 6 2)) >>> #(1 2 3 4 5 6)"
	
	| set |
	set := (OrderedSet withAll: self) addAll: aCollection; yourself.
	^ self species withAll: set getOrderedList
]
