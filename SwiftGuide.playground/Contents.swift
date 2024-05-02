import UIKit

// Actor

actor Counter {
    private var count = 0

    func increment() {
        count += 1
    }

    func getCount() -> Int {
        return count
    }
}

let counter = Counter()

Task {
    await counter.increment()
    print("Count: \(await counter.getCount())")
}

// Using async await

func fetchData() async throws -> Data {
    let url = URL(string: "https://example.com/data")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

Task {
    do {
        let data = try await fetchData()
        print("Data received: \(data)")
    } catch {
        print("Error fetching data: \(error)")
    }
}

/*
 func fetchUserData() async throws -> UserData {
 let data = try await fetchData()
 let user = try JSONDecoder().decode(UserData.self, from: data)
 return user
 }
 
 Task {
 do {
 let user = try await fetchUserData()
 print("User data received: \(user)")
 } catch {
 print("Error fetching user data: \(error)")
 }
 }
 */
