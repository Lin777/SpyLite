Class {
	#name : #OrderedSet,
	#superclass : #Set,
	#instVars : [
		'orderedList'
	],
	#category : #SpyLite
}

{ #category : #accessing }
OrderedSet >> add: newObject [
	"Include newObject as one of the receiver's elements, but only if
	not already present. Answer newObject."

	| index |
	index := self scanFor: newObject.
	(array at: index) ifNil: 
		[self atNewIndex: index put: newObject asCollectionElement.
		self orderedList add: newObject].
	^ newObject
]

{ #category : #accessing }
OrderedSet >> orderedList [
	orderedList ifNil: [ orderedList := OrderedCollection new ].
	^ orderedList
]

{ #category : #accessing }
OrderedSet >> orderedList: anObject [
	orderedList := anObject
]
