//
//  SendableView.swift
//  Swift_SendableInActors
//
//  Created by Ambreen Bano on 13/10/25.
//

import SwiftUI

//What we can send in Actors?
//Actors are thread safe so we can only send what is thread safe
//1. We can send String, Int, Float, Dounble are value type(Thread safe)
//2. We can send Struct are value type(Thread safe)
//3. We can send Thread Safe Classes are Reference type(After Making Class Thread safe) - Normal class we can NOT send because we can send in Actor ONLY Thread safe types



//Actor DataManager
actor DataManger {
    static let shared = DataManger()
    
    //1. We can send String, Int, Float, Dounble are value type(Thread safe)
    func getDataWithNumber(numb: Int) {
        
    }
    
    //2. We can send Struct are value type(Thread safe)
    func getDataWithStruct(model: DataModel) {
        
    }
    
    //3. We can send Thread Safe Classes
    func getDataWithClass(class: DataModelClass) {
        
    }
}



//ViewModel Class
@Observable class SendableViewModel {
    
    func getData() {
        Task {
            //1. We can send String, Int, Float, Dounble are value type(Thread safe)
            await DataManger.shared.getDataWithNumber(numb: 5)
            
            //2. We can send Struct are value type(Thread safe)
            await DataManger.shared.getDataWithStruct(model: DataModel(id: 5, name: "Struct"))
            
            //3. We can send Thread Safe Classes
            await DataManger.shared.getDataWithClass(class: DataModelClass(title: "Class"))
        }
    }
}



//MARK: Struct for Sendable in Actors
//2. We can send Struct are value type(Thread safe)
//Sendable - Conform Struct with Sendable protocol to make it sendable in Actors
struct DataModel: Sendable {
    let id: Int
    var name: String
}




//MARK: Thread Safe Class for Sendable in Actors
//3. We can send Thread Safe Classes are Reference type(After Making Class Thread safe) - Normal class we can NOT send because we can send in Actor ONLY Thread safe types
//final - make class final so no one can inherit from this class
//let queue = DispatchQueue() - so all update will be on single queue to make property thread safe
//Sendable - Conform Class with Sendable protocol to make it sendable in Actors
//@unchecked Sendable - Class is not thread safe so compiler will give error, So, marking with @unchecked We are telling compiler don't check class for Sendable, we check ourself by making it thread safe
final class DataModelClass: @unchecked Sendable {
    var title: String
    
    let queue = DispatchQueue(label: "myQueueToMakeClassThreadSafe")

    init(title: String) {
        self.title = title
    }
    
    func updateTitle(title: String){
        queue.async {
            self.title = title
        }
    }
}




//View
struct SendableView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
        }
    }
}




#Preview {
    SendableView()
}
