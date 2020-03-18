Class {
	#name : #SLSummaryStatement,
	#superclass : #Object,
	#instVars : [
		'code',
		'executed'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #'as yet unclassified' }
SLSummaryStatement class >> with: string and: boolean [ 
	^ self new 
		code: string;
		executed: boolean
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

{ #category : #initialization }
SLSummaryStatement >> initialize [ 
	code := ''.
	executed := false
]
