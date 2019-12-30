"
I am a superclass to Profiler, PackageSpy, ClassSpy and MethodSpy.

"
Class {
	#name : #SpyLite,
	#superclass : #Object,
	#classInstVars : [
		'currentTestCase',
		'currentTestMethod',
		'currentTestMethodSpy'
	],
	#category : #'SpyLite-MetaModel'
}

{ #category : #tests }
SpyLite >> nameOf: anObject [ 
		^ (anObject isClass
				ifTrue: [ anObject name ]
				ifFalse: [ anObject class name ])
]
