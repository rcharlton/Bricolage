# Bricolage

A Swift Package containing a random assortment of useful types. 

Wholly incomplete documentation follows...

## Clamped
Constrains a value within a given range.

```swift
0.clamped(-10...10) // = 0
Int(-99).clamped(-10...10) // = -10
99.clamped(-10...10) // = 10

99.clamped(-10..<10) // = 9
```

## Configure
A functional configuration pattern.

```swift
let label = configure(UILabel()) {
    $0.text = "User Profile"
    $0.textColor = .systemGray
    $0.textAlignment = .center
}
```

## DependencyContainer
A solution for run-time dependency resolution.

Key features:
* Lazy / functional instantiation of concrete dependency instances
* Multiple resolvers for each key dependency type
* Shared or multiple instances
* Weak or strongly referenced shared instances
* Arbitrary resolver parameters

Simple usage:
```swift
let container = DependencyContainer()
try container.register(someProtocol.self, instance: conformingClassA())
...
let instance = try container.resolve(someProtocol.self)
```

Lazy instantiation of a shared, retained instance:
```swift
let container = DependencyContainer()
try container.register(someProtocol.self) { (resolver: DependencyResolving, parameters: Void) in
    try ClassA(with: resolver)
}
...
let instance = try container.resolve(someProtocol.self)
```

Pass parameters from the resolving call-site:
```swift
let container = DependencyContainer()
try container.register(someProtocol.self) { (resolver: DependencyResolving, parameters: MyConfig) in
    try ClassA(with: resolver, parameters)
}
...
let instance = try container.resolve(someProtocol.self, parameters: myConfig)
```

Resolve a dependency type in multiple different ways:
```swift
enum Traits {
    case variantA, variantB 
}
 
let container = DependencyContainer()
try container.register(Traits.variantA, someProtocol.self) { (resolver: DependencyResolving, parameters: SomeStruct) in
    try ClassA(with: resolver, parameters)
}
try container.register(Traits.variantB, someProtocol.self) { (resolver: DependencyResolving, parameters: SomeStruct) in
    try ClassB(with: resolver, parameters)
}
...
let instanceA = try container.resolve(someProtocol.self, using: Traits.variantA)
let instanceB = try container.resolve(someProtocol.self, using: Traits.variantB)
```

Instances can be re-instantiated for each resolution:
```swift
let container = DependencyContainer()
try container.register(
    someProtocol.self, 
    options: []
) { (resolver: DependencyResolving, parameters: SomeStruct) in
    try ClassA(with: parameters)
}
...
let instance1 = try container.resolve(someProtocol.self)
let instance2 = try container.resolve(someProtocol.self)
let instance3 = try container.resolve(someProtocol.self)
```

Instances can be shared but NOT retained so their lifetimes match the consumers' use:
```swift
let container = DependencyContainer()
try container.register(
    someProtocol.self, 
    options: [.shared]
) { (resolver: DependencyResolving, parameters: SomeStruct) in
    try ClassA(with: resolver, parameters)
}
...
var instance = try container.resolve(someProtocol.self)
```

## Swift.Result Helpers
Exception-free accessors for the success and failure associated values.

```swift
let result: Result<String, Error> = .success("Magrathea")

if result.success == "Magrathea" {
}

if let error = result.failure {
}
```

## WebClient
A simple URLSession wrapper which provides:
* Flexible endpoint representation
* Automatic decoding of success and failure types
* Automatic and robust error reporting
* Support for `Void` success or failure types
* JSON or custom decoding
* Cancellation support
* Combine wrapper

Example usage:
```swift
struct SearchEndpoint: Endpoint {

    typealias Success = GuideEntry
    typealias Failure = GuideError
 
    private let queryString: String

    private var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.path = "search/entry"
        urlComponents.queryItems = [URLQueryItem(name: "query", value: queryString)]
        return urlComponents
    }

    func urlRequest(relativeTo url: URL) -> URLRequest? {
        urlComponents
            .url(relativeTo: url)
            .flatMap { URLRequest(url: $0) }
    }

}

let webClient = WebClient(serviceURL: URL(string: "hitchhikersguide.com/api")!)
let searchQuery = SearchEndpoint(queryString: "themeaningoflifeuniverseandeverything")
let searchResults = try await webClient.invoke(searchQuery)
```
