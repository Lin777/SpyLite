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
	(array at: index) ifNil: [ self atNewIndex: index put: newObject asCollectionElement.].
	^ newObject
]

{ #category : #accessing }
OrderedSet >> atNewIndex: index put: anObject [
	(array at: index) ifNil: [ self orderedList add: anObject].
	array at: index put: anObject.
	tally := tally + 1.
	self fullCheck
]

{ #category : #accessing }
OrderedSet >> cleanOrderedList [
	self orderedList removeDuplicates
]

{ #category : #accessing }
OrderedSet >> getOrderedList [
	self cleanOrderedList.
	^ self orderedList
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

{ #category : #accessing }
OrderedSet >> remove: oldObject ifAbsent: aBlock [

	| index |
	index := self findElementOrNil: oldObject.
	(array at: index) == nil ifTrue: [ ^ aBlock value ].
	array at: index put: nil.
	orderedList remove: oldObject.
	tally := tally - 1.
	self fixCollisionsFrom: index.
	^ oldObject
]
