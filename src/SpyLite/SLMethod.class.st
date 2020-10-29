"
I wrap a plain Pharo method and accumulate information during the program execution.

I have a selector name and belong to a ClassSpy.

I containt the hooks used to collect the actual runtime information. Three methods are provided for that purpose:

#beforeRun:with:in: and 
#afterRun:with:in: are executed before and after the corresponding Smalltalk method.

These methods are by default empty; they should be overridden in subclasses of MethodSpy to collect relevant dynamic information. The 

#run:with:in method simply calls #beforeRun:with:in:, followed by the execution of the represented Smalltalk method, and ultimately calls #afterRun:with:in:.

The parameters passed to these methods are: the method name (as a symbol), the list of arguments, and the object that receives the intercepted message.
"
Class {
	#name : #SLMethod,
	#superclass : #SpyLite,
	#instVars : [
		'instrumentedMethod',
		'originalMethod',
		'selector',
		'classSpy'
	],
	#classInstVars : [
		'inMeta'
	],
	#category : #'SpyLite-MetaModel'
}

{ #category : #public }
SLMethod class >> isInMeta [
	^ inMeta 
]

{ #category : #public }
SLMethod class >> notIdentifiedMethod [
	^ self
]

{ #category : #public }
SLMethod class >> setInMeta [
	inMeta := true
]

{ #category : #public }
SLMethod class >> setInNonMeta [
	inMeta := false
]

{ #category : #hooks }
SLMethod class >> spyClassForMethod [
	^ self
]

{ #category : #delegation }
SLMethod >> = v [
	| vp |
	(v isKindOf: SLMethod)
		ifTrue: [ vp := v originalMethod ]
		ifFalse: [ vp := v ].
	
	^ self originalMethod == vp
]

{ #category : #hooks }
SLMethod >> afterRun: methodName with: listOfArguments in: receiver [

]

{ #category : #delegation }
SLMethod >> at: v [
	^ originalMethod at: v
]

{ #category : #hooks }
SLMethod >> beforeRun: methodName with: listOfArguments in: receiver [

]

{ #category : #contract }
SLMethod >> checkInvariant [
	self assert: [ selector notNil ].
	self assert: [ selector isKindOf: Symbol ].
	self assert: [ originalMethod isKindOf: CompiledMethod ].

	self assert: [ self profiler notNil ].

	self assert: [ self classSpy notNil ].
	self assert: [ self classSpy profiler == self profiler ].
	self assert: [ self classSpy profiler notNil ].	
	self assert: [ self classSpy profiler isKindOf: SLProfiler ].	

]

{ #category : #accessing }
SLMethod >> classSpy [
	^ classSpy
]

{ #category : #accessing }
SLMethod >> classSpy: anObject [
	classSpy := anObject
]

{ #category : #accessing }
SLMethod >> compiledMethod [
	^ self originalMethod
]

{ #category : #delegation }
SLMethod >> endPC [
	^ originalMethod endPC
]

{ #category : #hooks }
SLMethod >> flushCache [
	"Tell the interpreter to remove all references to this method from its method lookup cache, if it has one.  This primitive must be called whenever a method is defined or removed.
	NOTE:  Only one of two selective flush methods needs to be used.
	Squeak 2.2 and earlier uses 119 (See Symbol flushCache).
	Squeak 2.3 and later uses 116 (See CompiledMethod flushCache)."

"	<primitive: 116>"
]

{ #category : #delegation }
SLMethod >> getSourceFor: sel in: class [
	^ originalMethod getSourceFor: sel in: class
]

{ #category : #'accessing-computed' }
SLMethod >> getSpyOf: callingMethod [
	"Take as argument a compiled method"
	"Return nil if none"
	| clsSpy |
	
	"We are looking for an instance side method"
	callingMethod methodClass isMeta ifFalse: [ 
		clsSpy := self profiler classAt: callingMethod methodClass name ifNone: [ ^ nil ].
		^ clsSpy >> callingMethod selector ].
	
	"We are looking for a class side method"
	" callingMethod methodClass isMeta => true"
	clsSpy := self profiler classAt: callingMethod methodClass soleInstance name ifNone: [ ^ nil ].
	^ clsSpy metaclassSpy >> callingMethod selector 
]

{ #category : #testing }
SLMethod >> hasClassSpy [ 
	^ self classSpy notNil
]

{ #category : #testing }
SLMethod >> hasLiteral: v [
	^ self originalMethod hasLiteral: v
]

{ #category : #delegation }
SLMethod >> hasLiteralSuchThat: v [
	^ originalMethod hasLiteralSuchThat: v
]

{ #category : #delegation }
SLMethod >> hash [
	^ self originalMethod hash bitXor: super hash

]

{ #category : #delegation }
SLMethod >> initialPC [
	^ originalMethod initialPC
]

{ #category : #'initialize-release' }
SLMethod >> initialize [
	super initialize.

]

{ #category : #installing }
SLMethod >> install [
	"We do nothing if the method has been supressed"
	(self theClass methodDict includesKey: self selector) ifFalse: [ ^ self ].

	self assert: [ (self theClass methodDict at: self selector) isSpy not ].
	self assert: [ self originalMethod notNil ].
	self assert: [ self instrumentedMethod notNil ].
	self flushCache.
	
	"We update the original method, it may have changed since the uninstall"
	originalMethod := self theClass methodDict at: self selector.
	self theClass methodDict at: self selector put: self instrumentedMethod.
	
]

{ #category : #accessing }
SLMethod >> instrumentedMethod [
	^ instrumentedMethod
]

{ #category : #accessing }
SLMethod >> instrumentedMethod: aTemplateMethod [
	instrumentedMethod := aTemplateMethod
]

{ #category : #testing }
SLMethod >> isAbstract [
	"True if the original method is abstract"

	^ self originalMethod isAbstract
]

{ #category : #testing }
SLMethod >> isClassSide [
	
	^ (self classSpy className endsWith: 'class')
]

{ #category : #delegation }
SLMethod >> isConflict [
	^ originalMethod isConflict
]

{ #category : #testing }
SLMethod >> isMethodExisting [
	^ self theClass methodDict includesKey: self selector
]

{ #category : #testing }
SLMethod >> isMethodNotExisting [
	^ self isMethodExisting not
]

{ #category : #testing }
SLMethod >> isNotAMethodExtension [
	"True if I am a class extension"

	^ self originalMethod category first = $*
]

{ #category : #testing }
SLMethod >> isNotMethodExtension [
	"True if I am a class extension"

	^ self originalMethod category first ~= $*
]

{ #category : #testing }
SLMethod >> isNotQuick [
	^ originalMethod isQuick not
]

{ #category : #testing }
SLMethod >> isQuick [
	^ originalMethod isQuick
]

{ #category : #testing }
SLMethod >> isRequired [
	^ self originalMethod isRequired
]

{ #category : #testing }
SLMethod >> isRequired: marker [
	^ self originalMethod isRequired: marker
]

{ #category : #testing }
SLMethod >> isSpyMethod [
	^ true
]

{ #category : #testing }
SLMethod >> isTest [
	
	^ (self asString findString: 'test' startingAt: 0 caseSensitive: true) > 0 and: [(self classSpy isTestClass )]
]

{ #category : #testing }
SLMethod >> isUnary [
	^ self selector isUnary
]

{ #category : #delegation }
SLMethod >> last [
	^ originalMethod last
]

{ #category : #delegation }
SLMethod >> literalAt: v [
	^ originalMethod literalAt: v
]

{ #category : #delegation }
SLMethod >> literals [
	^ originalMethod literals
]

{ #category : #delegation }
SLMethod >> methodClass [
	^ originalMethod methodClass
]

{ #category : #'accessing-computed' }
SLMethod >> numberOfCalls [
	^ originalMethod messages size
]

{ #category : #'accessing-computed' }
SLMethod >> numberOfLinesOfCode [
	^ originalMethod  numberOfLinesOfCode

]

{ #category : #delegation }
SLMethod >> objectForDataStream: v [
	^ originalMethod objectForDataStream: v
]

{ #category : #accessing }
SLMethod >> originalMethod [
	originalMethod isSpy ifTrue: [ ^ originalMethod originalMethod ].
	^ originalMethod
]

{ #category : #accessing }
SLMethod >> originalMethod: aCompiledMethod [
	self assert: [ aCompiledMethod isSpy not ].
	originalMethod := aCompiledMethod 
]

{ #category : #'accessing-computed' }
SLMethod >> package [
	^ self classSpy packageSpy
]

{ #category : #delegation }
SLMethod >> pragmas [
	^ originalMethod pragmas
]

{ #category : #printing }
SLMethod >> printOn: stream [
	stream nextPut: $<.
	self classSpy ifNotNil:[ stream nextPutAll: (self theClass name asString).].
	stream nextPutAll: ('>>').
	self selector ifNotNil:[stream nextPutAll: (self selector asString).].
	stream nextPut: $>
]

{ #category : #'accessing-computed' }
SLMethod >> profiler [
	self package ifNil: [ ^ nil ].
	^ self package profiler
]

{ #category : #delegation }
SLMethod >> readDataFrom: v1 size: v2 [
	^ originalMethod readDataFrom: v1 size: v2
]

{ #category : #delegation }
SLMethod >> refersToLiteral: v [
	^ originalMethod refersToLiteral: v
]

{ #category : #hooks }
SLMethod >> returnValue: value [
]

{ #category : #hooks }
SLMethod >> run: methodName with: listOfArguments in: receiver [
	| v |
	self beforeRun: methodName with: listOfArguments in: receiver.
	self classSpy ifNotNil: [
		classSpy beforeEachExecution: methodName On: receiver with: listOfArguments ].
	
	v := originalMethod valueWithReceiver: receiver arguments: listOfArguments.
	self afterRun: methodName with: listOfArguments in: receiver.

	self classSpy ifNotNil: [ 
		classSpy afterEachExecution: methodName On: receiver with: listOfArguments ].
	self returnValue: v.

	^ v
]

{ #category : #accessing }
SLMethod >> selector [
	^ selector
]

{ #category : #hooks }
SLMethod >> selector: sel [
	selector := sel
]

{ #category : #'accessing-computed' }
SLMethod >> sourceCode [
	^ originalMethod getSourceFromFile 
]

{ #category : #delegation }
SLMethod >> sourcePointer [
	^ originalMethod sourcePointer
]

{ #category : #delegation }
SLMethod >> storeDataOn: v [
	^ originalMethod storeDataOn: v
]

{ #category : #delegation }
SLMethod >> storeOn: s [
	^ originalMethod storeOn: s
]

{ #category : #delegation }
SLMethod >> theClass [
	^ originalMethod methodClass
]

{ #category : #installing }
SLMethod >> uninstall [

	self theClass methodDict at: self selector put: self originalMethod.
	self flushCache
]

{ #category : #delegation }
SLMethod >> veryDeepCopyWith: v [
	^ originalMethod veryDeepCopyWith: v
]
