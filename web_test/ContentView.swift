//
//  ContentView.swift
//  web_test
//
//  Created by Haik Divanyan on 2/20/21.
//

import SwiftUI

struct Result: Codable {
    var name: String
    var surname: String
    var _id: String
    var __v: Int
}

struct Responce: Codable {
    var results: [Result]
}

struct ContentView: View {
    @State var results = [Result]()
    
    var body: some View {
        List(results, id: \._id) { item in
            VStack(alignment: .leading) {
                Text("\(item.name) \(item.surname)")
            }
        }
        .onAppear(perform: loadData)
    }
    
    private func loadData() {
        guard let url = URL(string: "http://localhost:3000/people-names") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in //get this data
            guard let data = data else { return } // the data that came back = data

            if let decodedData = try? JSONDecoder().decode(Responce.self, from: data) {
                print(decodedData) // not printing
                DispatchQueue.main.async { //put on main queue because it changes UI
                     
                    self.results = decodedData.results //update @State variable
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "error")")
        }.resume()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
