"
I represent the profiling data for a package.

Each instance has a name and contains a set of class spies, that is, for each class in the corresponding package, an instance of ClassSpy is created.
"
Class {
	#name : #SLPackage,
	#superclass : #SpyLite,
	#instVars : [
		'packageName',
		'classes',
		'profiler'
	],
	#category : #'SpyLite-MetaModel'
}

{ #category : #hooks }
SLPackage class >> spyClassForClass [
	^ SLClass
]

{ #category : #accessing }
SLPackage >> >> aSymbol [
	"we are accessing a method defined in a metaclass"
	(aSymbol includes: $ ) ifTrue: [ ^ (self >> aSymbol substrings first asSymbol) metaclassSpy ].
	
	^ self classAt: aSymbol
]

{ #category : #enumerating }
SLPackage >> allClassesSuchThat: aBlock [
	^ self classes select: aBlock
]

{ #category : #'accessing-computed' }
SLPackage >> allMethods [
	| coll |
	coll := OrderedCollection new.
	self classes do: [:cls | coll addAll: cls allMethods ].
	^ coll
]

{ #category : #enumerating }
SLPackage >> allMethodsSuchThat: aBlock [
	^ self allMethods select: aBlock
]

{ #category : #contract }
SLPackage >> checkInvariant [
	self assert: [ packageName notNil ].
	self assert: [ packageName isKindOf: ByteString ].
	self assert: [ self profiler notNil ].

	self assert: [ self classes notNil ].
	self assert: [ self classes allSatisfy: [ :c | c isKindOf: self class spyClassForClass ] ].
	self assert: [ self classes allSatisfy: [ :c | c package == self ] ].
	self assert: [ self classes allSatisfy: [ :c | c profiler == self profiler ]].
	
	self classes do: #checkInvariant
]

{ #category : #accessing }
SLPackage >> classAt: aSymbol [
	^ classes at: aSymbol ifAbsent: [ self error: 'Class ', aSymbol, ' not found']
]

{ #category : #accessing }
SLPackage >> classAt: aSymbol ifNone: aBlock [
	^ classes at: aSymbol ifAbsent: aBlock
	
]

{ #category : #accessing }
SLPackage >> classAt: aSymbol put: aClassType [
	self assert: [aSymbol isSymbol].
	
	aClassType className: aSymbol.
	"self class globalTypesAt: aClassType className put: aClassType."
	^ classes at: aSymbol put: aClassType
]

{ #category : #accessing }
SLPackage >> classes [ 
	^ classes
]

{ #category : #enumerating }
SLPackage >> classesDo: aBlockOrSymbol [
	^ self classes do: aBlockOrSymbol
]

{ #category : #testing }
SLPackage >> hasClassNamed: className [
	^ self classes includesKey: className asSymbol
]

{ #category : #'initialize-release' }
SLPackage >> initialize [ 
	super initialize.
	classes := Dictionary new 
]

{ #category : #accessing }
SLPackage >> packageName [
	^ packageName
]

{ #category : #accessing }
SLPackage >> packageName: nameAsString [
	packageName  := nameAsString asString
]

{ #category : #printing }
SLPackage >> printOn: stream [
	stream nextPutAll: '<<'.
	self packageName ifNotNil:[ stream nextPutAll: (self packageName asString).].
	stream nextPutAll: '>>'.
]

{ #category : #accessing }
SLPackage >> profiler [
	^ profiler
]

{ #category : #accessing }
SLPackage >> profiler: anObject [
	profiler := anObject
]
