"
SSTypeCollectorClass is a subclass of profiler Class that collects class types.
"
Class {
	#name : #SSTypeCollectorClass,
	#superclass : #SLClass,
	#category : #'SpyLite-TypeCollector'
}

{ #category : #hooks }
SSTypeCollectorClass class >> spyClassForMethod [
	 ^ SSTypeCollectorMethod
]

{ #category : #defaults }
SSTypeCollectorClass >> typeName [ 
	^ self className
]
