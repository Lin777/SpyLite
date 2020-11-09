Class {
	#name : #SLSummaryStatement,
	#superclass : #Object,
	#instVars : [
		'id',
		'code',
		'executed'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #'as yet unclassified' }
SLSummaryStatement class >> on: aBlock wasExecuted: aBoolean [
	^ self new 
		id: aBlock id;
		code: aBlock code;
		executed: aBoolean
]

{ #category : #'as yet unclassified' }
SLSummaryStatement class >> with: string and: boolean [ 
	^ self new 
		code: string;
		executed: boolean
]

{ #category : #comparing }
SLSummaryStatement >> = another [ 
	^ (self class = another class) 
		and: [ self executed = another executed ]
]

{ #category : #accessing }
SLSummaryStatement >> code [
	^ code
]

{ #category : #accessing }
SLSummaryStatement >> code: anObject [
	code := anObject
]

{ #category : #accessing }
SLSummaryStatement >> executed [
	^ executed
]

{ #category : #accessing }
SLSummaryStatement >> executed: anObject [
	executed := anObject
]

{ #category : #comparing }
SLSummaryStatement >> hash [ 
	^ executed hash
]

{ #category : #accessing }
SLSummaryStatement >> id [
	^ id
]

{ #category : #accessing }
SLSummaryStatement >> id: anObject [
	id := anObject
]

{ #category : #initialization }
SLSummaryStatement >> initialize [ 
	code := ''.
	executed := false
]
