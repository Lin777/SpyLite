"
SSTypeCollector is a subclass of Profiler that collects project types

Instance Variables
	scalars:		<Dictionary>
"
Class {
	#name : #SSTypeCollector,
	#superclass : #SLProfiler,
	#instVars : [
		'scalars',
		'orderedScalars'
	],
	#category : #'SpyLite-TypeCollector'
}

{ #category : #hooks }
SSTypeCollector class >> profile: aBlock onPackagesMatching: regex [

	^ (self profile: aBlock inPackagesMatching: regex) "asTypeInfo".
]

{ #category : #hooks }
SSTypeCollector class >> spyClassForPackage [
	 ^ SSTypeCollectorPackage
]

{ #category : #hooks }
SSTypeCollector class >> typeNameOf: anObject [
	^ anObject name
]

{ #category : #initialization }
SSTypeCollector >> addScalar: anObject [
  | value valueCollection nameOfClass |
  nameOfClass := self nameOf: anObject class.
  value := scalars at: nameOfClass ifAbsentPut: [ Set new ].
  valueCollection := orderedScalars at: nameOfClass ifAbsentPut: [ OrderedCollection new ].
  (value includes: anObject) ifFalse: [ valueCollection add: anObject ].
	value add: anObject.
	anObject isCollection ifTrue: [ [ | val |
			val := anObject class new.
			(value includes: val) ifFalse: [ valueCollection add: anObject class new ].
			value add: val ] on: Error do: [  ] ]
]

{ #category : #initialization }
SSTypeCollector >> initialize [
	super initialize.
	scalars := Dictionary new.
	orderedScalars := Dictionary new
]

{ #category : #initialization }
SSTypeCollector >> isScalar: anObject [
  ((self nameOf: anObject class) includesAll: 'BlockClosure') ifTrue: [ ^true ].
  self allClassesAsDictionary at: (self nameOf: anObject class) asSymbol ifAbsent: [ ^true ].
  ^false
]

{ #category : #accessing }
SSTypeCollector >> orderedScalars [
	^ orderedScalars
]

{ #category : #initialization }
SSTypeCollector >> scalars [
	^ scalars.
]
