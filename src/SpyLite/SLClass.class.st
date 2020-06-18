"
I represent the profiling data for a class.

My attributes are:
the classes name, 
a metaclass spy, and 
a set of method spies.

For each method in the corresponding class, I create a MethodSpy.

"
Class {
	#name : #SLClass,
	#superclass : #SpyLite,
	#instVars : [
		'methods',
		'className',
		'allSubclassesCache',
		'packageSpy',
		'metaclassSpy'
	],
	#category : #'SpyLite-MetaModel'
}

{ #category : #hooks }
SLClass class >> spyClassForMethod [
	^ SLMethod 
]

{ #category : #'accessing-computed' }
SLClass >> >> aSymbol [
	^ self localMethodAt: aSymbol
]

{ #category : #hooks }
SLClass >> afterEachExecution: messageName On: aReceiver with: arguments [
]

{ #category : #'accessing-computed' }
SLClass >> allMethods [
	^ self methods , self metaclassSpy methods
]

{ #category : #'accessing-computed' }
SLClass >> allSubclasses [
	|result|
	allSubclassesCache ifNotNil: [ ^ allSubclassesCache ].
	
	result := OrderedCollection new.
	self subclasses do: [:cls | result add: cls. result addAll: cls allSubclasses ].
	^ result
]

{ #category : #hooks }
SLClass >> beforeEachExecution: messageName On: aReceiver with: arguments [
]

{ #category : #hooks }
SLClass >> beforeEachExecution: messageName on: aReceiver with: arguments [
]

{ #category : #contract }
SLClass >> checkInvariant [
	self assert: [ className notNil ].
	self assert: [ className isKindOf: Symbol ].

	self assert: [ self profiler notNil ].

	self assert: [ self methods notNil ].
	self assert: [ self methods isCollection ].
	self assert: [ self methods allSatisfy: [:m| m isKindOf: SLMethod ] ].

	self assert: [ self class spyClassForMethod == self profiler class spyClassForMethod ].
	self assert: [ self class spyClassForMethod == self profiler class spyClassForMethod ].
	self assert: [ self class == self profiler class spyClassForClass ].
]

{ #category : #accessing }
SLClass >> className [
	^ className
]

{ #category : #accessing }
SLClass >> className: aSymbol [
	className := aSymbol
]

{ #category : #'accessing-computed' }
SLClass >> downwardLookupMethodsNamed: aSelector [
	^ (self allSubclasses select: [:cls | cls hasMethodNamed: aSelector])
			collect: [:cls | cls localMethodAt: aSelector ]
		
]

{ #category : #testing }
SLClass >> hasMethodNamed: aSelector [
	^ self localMethods includesKey: aSelector
]

{ #category : #'initialize-release' }
SLClass >> initialize [ 
	super initialize.
	 methods := OrderedDictionary new 
]

{ #category : #testing }
SLClass >> isClassPresent [
	^ Smalltalk globals includesKey: className 
]

{ #category : #testing }
SLClass >> isMeta [
  ^ self className includes: $ 
]

{ #category : #testing }
SLClass >> isSubclassOf: aClassSpy [
	"True of I am a subclass of aClassSpy"
	
	^ self == aClassSpy
		ifTrue: [ true ]
		ifFalse: [ 
			self superclass ifNil: [ ^ false ].
			self superclass isSubclassOf: aClassSpy ]
]

{ #category : #testing }
SLClass >> isTestClass [
	"Return true if the real class is a test case"
	
	^ self theClass inheritsFrom: TestCase.
]

{ #category : #'accessing-computed' }
SLClass >> localMethodAt: aSelector [
	^ self localMethods at: aSelector
]

{ #category : #'accessing-computed' }
SLClass >> localMethodAt: aSelector ifAbsent: aBlock [
	^ self localMethods at: aSelector ifAbsent: aBlock
]

{ #category : #'accessing-computed' }
SLClass >> localMethodAt: aSelector put:  value [
	^ self localMethods at: aSelector put: value
]

{ #category : #accessing }
SLClass >> localMethods [
	^ methods 
]

{ #category : #'accessing-computed' }
SLClass >> lookupMethodNamed: aSelector [
	^ (self hasMethodNamed: aSelector)
			ifTrue: [ self localMethodAt: aSelector ]
			ifFalse: [ self superclass lookupMethodNamed: aSelector ]
]

{ #category : #accessing }
SLClass >> metaclassSpy [
	^ metaclassSpy ifNil: 
		[ metaclassSpy := self class new className: (self nameOf: self theClass class) ; yourself ]
]

{ #category : #'accessing-computed' }
SLClass >> methods [ 
	^ methods values
]

{ #category : #'accessing-computed' }
SLClass >> methods: aDictionary [
	methods := aDictionary 
]

{ #category : #'accessing-computed' }
SLClass >> nonMetaClassName [
	^ (self isMeta
		ifTrue: [ self className copyFrom: 1 to: ((self className indexOf: $ ) - 1)] 
		ifFalse: [ self className ]) asSymbol
]

{ #category : #'accessing-computed' }
SLClass >> numberOfAllMethods [
	^ self allMethods size
]

{ #category : #accessing }
SLClass >> package [
	^ packageSpy 
]

{ #category : #accessing }
SLClass >> packageSpy [
	^ packageSpy
]

{ #category : #accessing }
SLClass >> packageSpy: anObject [ 
	packageSpy := anObject.
	metaclassSpy ifNotNil: [ metaclassSpy packageSpy: anObject ]
]

{ #category : #printing }
SLClass >> printOn: stream [
	stream nextPut: $<.
	stream nextPutAll: (self className printString).
	stream nextPut: $>
]

{ #category : #'accessing-computed' }
SLClass >> profiler [
	^ self package profiler
]

{ #category : #removing }
SLClass >> removeMethod: aCompiledMethod [ 
    (aCompiledMethod methodClass name endsWith: 'class') ifTrue: [ 
        self metaclassSpy methods removeKey: aCompiledMethod selector ]
    ifFalse: [ methods removeKey: aCompiledMethod selector ]
]

{ #category : #'accessing-computed' }
SLClass >> subclasses [
	^ self profiler allClassesSuchThat: [:cls | cls superclass == self]
]

{ #category : #accessing }
SLClass >> superclass [
	^ self profiler classAt: self theClass superclass name ifNone: [nil]
]

{ #category : #accessing }
SLClass >> theClass [
	^ self isMeta
		ifTrue: [ (Smalltalk at: self nonMetaClassName) class ]
		ifFalse: [ Smalltalk at: self className ]

]

{ #category : #'accessing-computed' }
SLClass >> theNonMetaClass [ 
	"Return the non metaclass spy for the receiver"
	
	self isMeta ifFalse: [ ^ self ].
	^ self packageSpy >> self nonMetaClassName
]

{ #category : #testing }
SLClass >> understandMethodNamed: aSelector [
	(self hasMethodNamed: aSelector)
		ifTrue: [ ^ true ].
	
	self superclass ifNil: [ ^ false ].
	
	^ self superclass understandMethodNamed: aSelector
]

{ #category : #'accessing-computed' }
SLClass >> withAllSubclasses [
	^ {self}, self allSubclasses
]
