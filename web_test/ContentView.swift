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
    var __v: Int = 0
    
//    init(name: String, surname: String) {
//        self.name = name
//        self.surname = surname
//    }
}

struct sendDataStruct: Codable {
    var name: String
    var surname: String
    
    init(name: String, surname: String) {
        self.name = name
        self.surname = surname
    }
}

struct ContentView: View {
    @State var results = [Result]()
    @State var deleteInput: String = ""
    @State var nameInput: String = ""
    @State var surnameInput: String = ""
    
    var body: some View {
        
        VStack {
            List(results, id: \._id) { item in
                VStack(alignment: .leading) {
                    Text("\(item.name) \(item.surname)")
                }
            }
            .frame(width: 400, height: 450, alignment: .center)
            
            Spacer()
            
            TextField("Enter Name:", text: $nameInput)
                .padding()
            
            TextField("Enter Surname:", text: $surnameInput)
                .padding()
            
            Button("Submit") {
                if nameInput == "" {
                    print("name is required")
                    return
                }
                if surnameInput == "" {
                    print("surname is required")
                    return
                }
                let inputName = sendDataStruct(name: nameInput, surname: surnameInput)
                sendData(inputName) // input was valid
                
                
            }
                .padding()
            
            TextField("Enter Name To Delete:", text: $deleteInput)
                .padding()
            
            Button("Delete") { deleteData(nameToDelete: deleteInput)}
            
            Spacer()
        }
        .onAppear(perform: loadData)
    }
    
    private func loadData() {
        guard let url = URL(string: "http://localhost:3000/people-names") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in //get this data
            guard let data = data else { return } // the data that came back = data
            
            if let decodedData = try? JSONDecoder().decode([Result].self, from: data) {
                DispatchQueue.main.async { //put on main queue because it changes UI
                    
                    self.results = decodedData //update @State variable
                }
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "error")")
            }
        }.resume()
    }
    
    private func sendData(_ inputName: sendDataStruct) {
        guard let encoded = try? JSONEncoder().encode(inputName) else {
            print("failed to encode data")
            return
        }
        
        let url = URL(string: "http://localhost:3000/login")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            DispatchQueue.main.async {
                loadData()
            }
        }.resume()
    }
    
    private func deleteData(nameToDelete: String) {
        var id: String?
        for result in results {
            if result.name == nameToDelete {
                id = result._id
            }
        }
        guard id != nil else {
            print("error, cannot find \(nameToDelete)")
            return
        }
        let url = URL(string: "http://localhost:3000/delete-name/\(id!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                loadData()
            }
            print("Data has been deleted!")
        }.resume()

    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
