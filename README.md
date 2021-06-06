# Bricolage

A Swift Package containing a somewhat random assortment of useful Swift types. 

Wholly incomplete documentation follows...

## Clamped
Constrains a value within a given range.

```swift
Int(0).clamped(-10...10) // = 0
Int(-99).clamped(-10...10) // = -10
Int(99).clamped(-10...10) // = 10

Int(99).clamped(-10..<10) // = 9
```

## Configure
```swift
let label = configure(UILabel()) {
    $0.text = "User Profile"
    $0.textColor = .systemGray
    $0.textAlignment = .center
}
```

## Swift.Result extensions
```swift
let result: Result<String, Error> = .success("Magrathea")

if result.success == "Magrathea" {
}

if let error = result.failure {
}
```

## WebClient: a simple URLSession wrapper
```swift
struct SearchGuideEndpoint: BasicEndpoint {

    typealias Success = GuideEntry
    typealias Failure = StatusCodeResponseDecodingError<GuideError>
    typealias FailureDetails = GuideError

    let queryString: String

    private var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.path = "search/entry"
        urlComponents.queryItems = [URLQueryItem(name: "query", value: queryString)]
        return urlComponents
    }

    func urlRequest(relativeTo url: URL) -> URLRequest? {
        urlComponents
            .url(relativeTo: url)
            .map { URLRequest(url: $0) }
    }

}

let webClient = WebClient(serviceURL: URL(string: "hitchhikersguide.com/api")!)
let searchQuery = SearchGuideEndpoint(queryString: "themeaningoflifeuniverseandeverything")
let canceller = webClient.invoke(searchQuery) { result in 
}
```
