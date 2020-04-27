Class {
	#name : #SLBlock,
	#superclass : #Object,
	#instVars : [
		'id',
		'executed',
		'numberOfStatements',
		'start',
		'stop',
		'code'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #'instance creation' }
SLBlock class >> new [ 	
	^ super new initialize
]

{ #category : #accessing }
SLBlock >> code [
	^ code
]

{ #category : #accessing }
SLBlock >> code: anObject [
	code := anObject
]

{ #category : #accessing }
SLBlock >> executed [
	executed := true.
]

{ #category : #accessing }
SLBlock >> id [
	^ id
]

{ #category : #accessing }
SLBlock >> id: anObject [
	id := anObject
]

{ #category : #initialization }
SLBlock >> initialize [
	super initialize.
	executed := false.
	numberOfStatements := 0.
	code := ''
]

{ #category : #updating }
SLBlock >> noExecuted [
	executed := false.
	
]

{ #category : #accessing }
SLBlock >> numberOfStatements [
	^ numberOfStatements
]

{ #category : #accessing }
SLBlock >> numberOfStatements: anObject [
	numberOfStatements := anObject
]

{ #category : #accessing }
SLBlock >> start [
	^ start
]

{ #category : #accessing }
SLBlock >> start: anObject [
	start := anObject
]

{ #category : #accessing }
SLBlock >> stop [
	^ stop
]

{ #category : #accessing }
SLBlock >> stop: anObject [
	stop := anObject
]

{ #category : #accessing }
SLBlock >> wasExecuted [
	^ executed.
]
