"
SSTypeCollector is a subclass of Profiler that collects project types

Instance Variables
	scalars:		<Dictionary>
"
Class {
	#name : #SSTypeCollector,
	#superclass : #SLProfiler,
	#instVars : [
		'scalars'
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
  | value |
  value := scalars at: (self nameOf: anObject class) ifAbsentPut: [ Set new ].
  "value add: anObject.
	anObject isCollection ifTrue: [ [ value add: anObject class new ] on: Error do: [  ] ]"
]

{ #category : #initialization }
SSTypeCollector >> initialize [
	super initialize.
	scalars := Dictionary new
]

{ #category : #initialization }
SSTypeCollector >> isScalar: anObject [
  ((self nameOf: anObject class) includesAll: 'BlockClosure') ifTrue: [ ^true ].
  self allClassesAsDictionary at: (self nameOf: anObject class) asSymbol ifAbsent: [ ^true ].
  ^false
]

{ #category : #initialization }
SSTypeCollector >> scalars [
	^ scalars.
]
