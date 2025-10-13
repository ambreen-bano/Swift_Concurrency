//
//  DoTryCatchThrow.swift
//  Swift_DoTryCatchThrow
//
//  Created by Ambreen Bano on 11/10/25.
//

import SwiftUI

//Model
struct Model {
    let title: String
}


//Singleton class for Networking
class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    private init() {
    }
    
    let isActive: Bool = false
    
    //Using Tuple
    func fetchData() ->  (title: String?, error: Error?) {
        if isActive {
            return ("Active", nil)
        } else {
            return ("nil", URLError(.badURL))
        }
    }
    
    //Using Result Type - Easy to handle server return data or error using switch case
    func fetchData2() ->  Result<String,Error> {
        if isActive {
            return .success("Active")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    //Using throws - If No Error then this will return String else will throw error
    func fetchData3() throws ->  String {
        if isActive {
            return "Active"
        } else {
            throw URLError(.badURL)
        }
    }
}




//View Model
@Observable class DoTryCatchThrowViewModel {

    var dataModel: Model?
    
    init() {
        //getData()
        //getData2()
        getData3()
    }
    
    func getData() {
        let fetchedData = NetworkManager.shared.fetchData()
        if let title = fetchedData.title {
            dataModel = Model(title: title)
        } else if let error = fetchedData.error {
            dataModel = Model(title: error.localizedDescription)
        }
    }
    
    
    func getData2() {
        let result = NetworkManager.shared.fetchData2()
        switch result {
        case .success(let title):
            dataModel = Model(title: title)
        case .failure(let error):
            dataModel = Model(title: error.localizedDescription)
        }
    }
    
    
    func getData3() {
        //1. Using "try", Mandatory to use "do-catch" block
        do {
            //If the function is throws then we NEED to call it with "try"
            //If we are using "try" then we NEED to call it inside "do-catch" block
            //If we are using "try" then "let title" is String type
            let title = try NetworkManager.shared.fetchData3()
            dataModel = Model(title: title)
            
            //Inside do{} block, we can have any number of "try" statements
            //Inside do{} block if ANY of the "try" throws an error then next lines will not execute, it will exit "do" block and jump to "catch" block
            let _ = try NetworkManager.shared.fetchData3() //If it throws then next lines will not execute
            let _ = try NetworkManager.shared.fetchData3()
            let _ = try NetworkManager.shared.fetchData3()
        } catch let error { // we can write it without "let error" also
            dataModel = Model(title: error.localizedDescription)
        }
        
        //2. Using "try?", OPTIONAL to use "do-catch" block
        //If we are using "try?" then we DON'T NEED to call it inside "do-catch" block
        //If we are using "try?" then using "do-catch" block is OPTIONAL, we can use if want to catch errors
        //If we are using "try?" then "let title" is OPTIONAL String? type
        let title = try? NetworkManager.shared.fetchData3()
        dataModel = Model(title: title ?? "Some Error Occurred")
        
        
        //If we have mix of "try" and "try?" inside "do-catch" block
        do {
            //Inside do{} block if ANY of the OPTIONAL "try?" throws an error then next lines will CONTINUE to execute as we are not catching it if it is marked as OPTIONAL "try?"
            let _ = try? NetworkManager.shared.fetchData3() //If it throws then next lines will STIL execute
            let _ = try NetworkManager.shared.fetchData3()
            let _ = try NetworkManager.shared.fetchData3()
        } catch let error {
            dataModel = Model(title: error.localizedDescription)
        }
    }
}



//View
struct DoTryCatchThrow: View {
    @State var doTryCatchThrowVM: DoTryCatchThrowViewModel = DoTryCatchThrowViewModel()
    
    
    var body: some View {
        Text(doTryCatchThrowVM.dataModel?.title ?? "NO Data...")
    }
}




#Preview {
    DoTryCatchThrow()
}
