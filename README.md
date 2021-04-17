# Bricolage

A somewhat random assortment of useful Swift types. Wholly incomplete documentation follows...

## Configure
```swift
let label = configure(UILabel()) {
    $0.text = "User Profile"
    $0.textColor = .systemGray
    $0.textAlignment = .center
}
```

## WebClient: a simple URLSession wrapper
```swift
struct SearchEndpoint: BasicEndpoint {

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
let searchEndpoint = SearchEndpoint(queryString: "themeaningoflifeuniverseandeverything")
let canceller = webClient.invoke(someEndpoint) { result in 
}
```
