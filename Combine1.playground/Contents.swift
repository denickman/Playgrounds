import UIKit
import Combine

var cancellables = Set<AnyCancellable>()

let yoPublisher = Just("Yo")

let pub1 = yoPublisher.sink { value in
    print("yo publisher value is:", value)
}.store(in: &cancellables)

// cancellable is not required
//pub1.cancel()


let numbersPublisher = [1,2,3,4,5].publisher
let doublePublisher = numbersPublisher.map { $0 * 2 }

enum NumberError: Error {
    case operationFailed
}
/*
 let doublePublisherWithExc = numbersPublisher
 .tryMap { number in
 if number == 4 {
 throw NumberError.operationFailed
 }
 return number * 4
 }
 .catch { failure in
 if let numberError = failure as? NumberError {
 print("number error is", numberError)
 }
 return Just(0)
 }
 
 let cncl1 = doublePublisherWithExc.sink { completion in
 switch completion {
 case .finished:
 print("finish")
 case .failure(let error):
 print("show error", error)
 }
 } receiveValue: { value in
 print(value)
 }
 
 print("---------------------------------")
 
 let doublePublisherWithExc2 = numbersPublisher
 .tryMap { number in
 if number == 4 {
 throw NumberError.operationFailed
 }
 return number * 2
 }
 .mapError { error in
 return NumberError.operationFailed
 }
 
 let cncl2 = doublePublisherWithExc2.sink { completion in
 switch completion {
 case .finished:
 print("finish")
 case .failure(let error):
 print("show error", error)
 }
 } receiveValue: { value in
 print(value)
 }
 
 
 
 
 
 
 
 let pub2 = doublePublisher.sink { value in
 print(value)
 }
 
 let timePublisher = Timer.publish(every: 1, on: .main, in: .common)
 //let pub3 = timePublisher.autoconnect().sink { timestamp in
 //    print("timestamp is:", timestamp)
 //}
 
 // autoconnect - automatic connect to publisher
 // if you do not want 'autoconnect' you can set it explicitly
 //let cancellable = timePublisher.connect() // Явный вызов connect()
 
 
 let numberPublisher = (1...30).publisher
 let pub3 = numberPublisher.sink { value in
 print(value)
 }
 
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
 // will cancel only subscription, not publish values
 pub3.cancel()
 })
 
 
 
 
 
 // filter operators
 
 let numberPublisher1 = (1...10).publisher
 
 let evenNumberPublisher1 = numberPublisher.filter { $0 % 2 == 0 }
 
 let cancellable = evenNumberPublisher1.sink { value in
 print(value)
 }
 
 // compactMap
 
 let strPublisher = ["1", "2", "3", "A", "B", "C"].publisher
 
 let nmbPublisher1 = strPublisher.compactMap { Int($0) }
 
 nmbPublisher1.sink { value in
 print(value)
 }
 
 // debounce
 
 let txtPublisher1 = PassthroughSubject<String, Never>()
 
 let dbPublisher = txtPublisher1.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
 
 let cncl3 = dbPublisher.sink { value in
 print(value)
 }
 
 txtPublisher1.send("a")
 txtPublisher1.send("A")
 txtPublisher1.send("B")
 txtPublisher1.send("C")
 txtPublisher1.send("E")
 
 
 
 // combining operators
 
 // combineLatest
 
 let pub4 = CurrentValueSubject<Int, Never>(1)
 let pub5 = CurrentValueSubject<Int, Never>(2)
 //let pub6 = CurrentValueSubject<String, Never>("hello")
 // we can use different types for combineLatest, like int and string
 
 let cmbPublisher = pub4.combineLatest(pub5)
 
 let cncl4 = cmbPublisher.sink { item1, item2 in
 print("Value1: \(item1), Value2: \(item2)")
 }
 
 pub4.send(555)
 pub5.send(666)
 
 
 
 // zip
 
 let pub6 = [1,2,3,4].publisher
 let pub7 = ["A", "b", "C"].publisher
 let pub8 = ["x", "y", "z"].publisher
 
 let zipperPublisher = Publishers.Zip3(pub6, pub7, pub8) // return tuple in sink
 
 
 let zip = pub6.zip(pub7)
 
 let cncl5 = zip.sink { value1, value2 in
 print("\(value1), \(value2)")
 }
 
 
 // switchToLatest
 
 let outerPublisher = PassthroughSubject<AnyPublisher<Int, Never>, Never>()
 let innerPublisher1 = CurrentValueSubject<Int, Never>(1)
 let innerPublisher2 = CurrentValueSubject<Int, Never>(2)
 
 let cncl6 = outerPublisher
 .switchToLatest()
 .sink { value in
 print(value)
 }
 
 outerPublisher.send(AnyPublisher(innerPublisher1))
 innerPublisher1.send(2)
 
 outerPublisher.send(AnyPublisher(innerPublisher2))
 innerPublisher2.send(0)
 
 
 
 
 
 //The switchToLatest operator in Combine is used to switch to the latest publisher emitted by a higher-order publisher. This is particularly useful in scenarios where you have a stream of publishers and want to only receive elements from the most recent publisher while ignoring previous publishers.
 
 // Create two publishers that emit integers
 let publisher1 = PassthroughSubject<Int, Never>()
 let publisher2 = PassthroughSubject<Int, Never>()
 
 // Create an outer publisher that emits publishers
 let outerPublisher1 = PassthroughSubject<AnyPublisher<Int, Never>, Never>()
 
 // Subscribe to the combined stream using switchToLatest
 let subscription1 = outerPublisher
 .switchToLatest()
 .sink { value in
 print("Received value: \(value)")
 }
 
 // Send publisher1 through the outerPublisher
 outerPublisher1.send(AnyPublisher(publisher1))
 
 // Send some values through publisher1
 publisher1.send(1)
 publisher1.send(2)
 
 // Switch to publisher2 by sending it through outerPublisher
 outerPublisher1.send(AnyPublisher(publisher2))
 
 // Send some values through publisher2
 publisher2.send(10)
 publisher2.send(20)
 
 // Output:
 // Received value: 1
 // Received value: 2
 // Received value: 10
 // Received value: 20
 
 
 
 // replaceError with single value
 
 let numPub1 = [1,2,3,4,5].publisher
 
 let transformNumPub1 = numPub1
 .tryMap { value in
 if value == 3 {
 throw NumberError.operationFailed
 }
 return value * 2
 }.replaceError(with: 0)
 
 
 let cncl8 = transformNumPub1.sink { value in
 print(value)
 }
 
 
 // replaceError with another publisher
 
 let fallbackPublisher = Just(-1)
 
 let transformNumPub2 = numPub1
 .tryMap { value in
 if value == 3 {
 throw NumberError.operationFailed
 }
 return Just(value * 2)
 }.replaceError(with: fallbackPublisher)
 
 
 let cncl9 = transformNumPub2.sink { publisher in
 let _ = publisher.sink { value in
 print(value)
 }
 }
 
 
 // retry
 
 let publisher = PassthroughSubject<Int, Error>()
 
 let retriedPublisher = publisher
 .tryMap { value in
 if value == 3 {
 throw NumberError.operationFailed
 }
 return value
 }.retry(2)
 
 let cancellable = retriedPublisher.sink { completion in
 switch completion {
 case .finished:
 print("Publisher has completed")
 case .failure(let error):
 print(error.localizedDescription)
 }
 } receiveValue: { value in
 print(value)
 }
 
 
 publisher.send(1)
 
 publisher.send(3) // failed 1 time
 publisher.send(4)
 publisher.send(5)
 
 publisher.send(3) // failed 2 times
 publisher.send(6)
 publisher.send(7)
 
 publisher.send(3) // failed 3 times - cause error
 publisher.send(8) // not emit
 
 
 
 
 
 
 // subjects - publish the values and also can subscribe
 
 //PassthroughSubject
 
 let ps1 = PassthroughSubject<Int, Never>()
 
 let cncl10 = ps1.sink { value in
 print(value)
 }
 
 ps1.send(10)
 ps1.send(20)
 
 let cvs1 = CurrentValueSubject<Int, Never>(1)
 
 let cncl11 = cvs1.sink { value in
 print(value)
 }
 
 cvs1.send(11)
 print(cvs1.value) // return 11 because it retains the last value
 
 // CUSTOM SUBJECTS
 
 class EvenSubject<Failure: Error>: Subject {
 
 typealias Output = Int
 
 private let wrapped: PassthroughSubject<Int, Failure>
 
 init(initialValue: Int) {
 self.wrapped = PassthroughSubject()
 //        let evenValue = initialValue % 2 == 0 ? initialValue : 0
 send(initialValue)
 }
 
 func send(subscription: Subscription) {
 wrapped.send(subscription: subscription)
 }
 
 
 func send(_ value: Int) {
 if value % 2 == 0 {
 wrapped.send(value)
 }
 }
 
 func send(completion: Subscribers.Completion<Failure>) {
 wrapped.send(completion: completion)
 }
 
 func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Int == S.Input {
 wrapped.receive(subscriber: subscriber)
 }
 
 }
 
 
 let subject = EvenSubject<Never>(initialValue: 4)
 
 let cncl12 = subject.sink { value in
 print(value)
 }
 
 subject.send(12)
 subject.send(13)
 subject.send(20)
 
 
 
 
 class WeatherClient {
 let updates = PassthroughSubject<Int, Never>()
 
 func fetchWeather() {
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { [weak self] in
 self?.updates.send(Int.random(in: 0...10))
 })
 }
 }
 
 
 let client = WeatherClient()
 
 let cncl13 = client.updates.sink { item in
 print(item)
 }
 
 client.fetchWeather()
 
 
 
 // networking
 
 /*
  {
  "userId": 1,
  "id": 1,
  "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
  "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
  }
  */
 
 enum NetworkError: Error {
 case badServiceRespose
 }
 
 struct Post: Codable {
 let userId: Int
 let id: Int
 let title: String
 let body: String
 }
 
 func fetchPosts() -> AnyPublisher<[Post], Error> {
 let url = URL(string: "http://jsonplaceholder.typicode.com/posts")!
 return URLSession.shared.dataTaskPublisher(for: url)
 //        .map(\.data)
 .tryMap { data, response in
 guard let httpResponse = response as? HTTPURLResponse else {
 throw NetworkError.badServiceRespose
 }
 return data
 }
 .decode(type: [Post].self, decoder: JSONDecoder())
 .retry(3) // if there is a problem with network try request 3 times + 1 time of original request
 .receive(on: DispatchQueue.main) // set a thread when data will have been received
 .eraseToAnyPublisher()
 }
 
 var cancellables2: Set<AnyCancellable> = []
 
 fetchPosts()
 .sink { completion in
 switch completion {
 case .finished:
 print("Update ui")
 case .failure(let error):
 print(error.localizedDescription)
 }
 } receiveValue: { posts in
 print(">> Posts >> ")
 print(posts)
 }.store(in: &cancellables2)
 
 
 
 
 // Combine requests together
 
 struct MovieResponse: Decodable {
 let search: [Movie]
 }
 
 struct Movie: Decodable {
 let title: String
 
 private enum CodingKeys: String, CodingKey {
 case title = "Title"
 }
 }
 
 func fetchMovies(_ searchString: String) -> AnyPublisher<MovieResponse, Error> {
 let url = URL(string: "http://www.omdbapi.com/?s=\(searchString)&page=2&apiKey=564727fa")!
 return URLSession.shared.dataTaskPublisher(for: url)
 .map(\.data)
 .decode(type: MovieResponse.self, decoder: JSONDecoder())
 .receive(on: DispatchQueue.main)
 .eraseToAnyPublisher()
 }
 
 
 Publishers.CombineLatest(fetchMovies("Batman"), fetchMovies("Spiderman"))
 .sink { _  in
 
 } receiveValue: { value1, value2 in
 print(value1.search, value2.search)
 }.store(in: &cancellables2)
 
 
 
 
 // Custom operators
 
 // custom filter operator
 
 // filter even values
 extension Publisher where Output == Int {
 
 func filterEvenNumbers() -> AnyPublisher<Int, Failure> {
 return self.filter { $0 % 2 == 0 }
 .eraseToAnyPublisher()
 }
 
 func filterNumberGreaterThen(_ value: Int) -> AnyPublisher<Int, Failure> {
 return self.filter { $0 > value }
 .eraseToAnyPublisher()
 }
 }
 
 let pblsh1 = [1,2,3].publisher
 
 let cncl14 = pblsh1.filterEvenNumbers().sink { value in
 print("even:", value)
 }
 
 let cncl15 = pblsh1.filterNumberGreaterThen(4)
 .sink { value in
 print("filtered:", value)
 }
 
 
 
 extension Publisher {
 func mapAndFilter<T>(_ transform: @escaping (Output) -> T, _ isIncluded: @escaping (T) -> Bool) -> AnyPublisher<T, Failure> {
 return self
 .map { transform($0) }
 .filter { isIncluded($0) }
 .eraseToAnyPublisher()
 }
 }
 
 let cnc16 = pblsh1
 .mapAndFilter({$0 * 2}) { value in
 return value % 2 == 0
 }.sink { value in
 print(value)
 }
 
 
 
 
 
 let pb1 = [1,2,3,4,5].publisher
 
 let cncl1 = pb1
 .map { $0 * 3 }
 .filter { $0 % 2 == 0 }
 .print("debug")
 .sink { value in
 print(value)
 }
 
 let cncl2 = pb1
 .handleEvents { _ in
 print("1 subsription is received")
 } receiveOutput: { value in
 print("2 output:", value)
 } receiveCompletion: { completion in
 print("3 completion:", completion)
 } receiveCancel: {
 print("4 cancel:")
 } receiveRequest:  { _ in
 print("5 receive request")
 }
 .map { $0 * 3 }
 .filter { $0 % 2 == 0 }
 .sink { value in
 print(value)
 }
 
 
 
 
 // Tests
 
 import XCTest
 
 class HelloCombineTests: XCTestCase {
 func testFirstTest() {
 let exp = XCTestExpectation(description: "Received value")
 let publisher = Just("Hello world")
 
 let _ = publisher.sink { value in
 XCTAssertEqual(value, "Hello world")
 exp.fulfill()
 }
 
 wait(for: [exp], timeout: 1.0)
 }
 }
 
 
 HelloCombineTests.defaultTestSuite.run()
 
 */


// Future: A publisher that eventually produces a single value and then finishes or fails.
let futurePublisher = Future<Int, Error> { promise in
    DispatchQueue.global().async {
        // Simulate a long-running task
        Thread.sleep(forTimeInterval: 2)
        
        // Fulfill the promise with a value
        promise(.success(42))
    }
}

let cancellable = futurePublisher
    .sink(receiveCompletion: {
        print("future completion:")
        print($0)
    },
          receiveValue: {
        print("future received values:")
        print($0)
    })


//Deferred: A publisher that waits until a subscriber attaches to it before creating a publisher for that subscriber.

let deferredPublisher = Deferred {
    Future<Int, Never> { promise in
        DispatchQueue.global().async {
            // Simulate a long-running task
            Thread.sleep(forTimeInterval: 5)
            
            // Fulfill the promise with a value
            promise(.success(666))
        }
    }
}

let cancellable2 = deferredPublisher
    .sink(receiveCompletion: { 
        print("deffered receice completion:")
        print($0) },
          receiveValue: { 
        print("deferred receice completion:")
        print($0) })


// Empty: A publisher that immediately finishes without emitting any values.

/*
 Suppose you have a user interface where you need to display some data fetched from a server, but there are certain conditions where no data should be displayed. For instance, let's say you have a feature where you show a list of recent transactions, but if the user hasn't made any transactions yet, you want to display a message indicating that there are no transactions to show.

 You can use Empty to represent the absence of data in such cases. Here's a simplified example using SwiftUI:
 */

let emptyPublisher = Empty<Int, Never>()

let cancellable3 = emptyPublisher
    .sink(receiveCompletion: {
        print("emtpy receice completion:")
        print($0) },
          receiveValue: { 
        print("emtpy receice value:")
        print($0) })


//Fail: A publisher that immediately fails with the specified error.

let failPublisher = Fail<Int, Error>(error: NSError(domain: "example", code: 500, userInfo: nil))

let cancellable4 = failPublisher
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print($0) })
