Class {
	#name : #SLClassCoverage,
	#superclass : #SLClass,
	#category : #'SpyLite-Coverage'
}

{ #category : #hooks }
SLClassCoverage class >> spyClassForMethod [
	^ SLMethodCoverage
]
