"
SSTypeCollectorPackage is a subclass of Package that collects packages types
"
Class {
	#name : #SSTypeCollectorPackage,
	#superclass : #SLPackage,
	#category : #'SpyLite-TypeCollector'
}

{ #category : #hooks }
SSTypeCollectorPackage class >> spyClassForClass [
	 ^ SSTypeCollectorClass
]
