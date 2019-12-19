Class {
	#name : #SLPackageCoverage,
	#superclass : #SLPackage,
	#category : #'SpyLite-Coverage'
}

{ #category : #hooks }
SLPackageCoverage class >> spyClassForClass [
	^ SLClassCoverage
]
