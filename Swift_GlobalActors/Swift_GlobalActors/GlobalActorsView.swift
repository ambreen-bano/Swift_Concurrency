//
//  GlobalActorsView.swift
//  Swift_GlobalActors
//
//  Created by Ambreen Bano on 13/10/25.
//


import SwiftUI


//App can have ONLY ONE Global Actor
//Global Actor can be ONLY final-Class or Struct to make it thread safe
//Global Actor can ONLY have one SINGLE shared Instance in App
//Pre exsisting Available Global Actor is - @MainActor
@globalActor final class MyAppGlobalActor {
//@globalActor struct MyAppGlobalActor {
    static let shared: some Actor = DataManger.shared
}



//Actor DataManager
actor DataManger {
    static let shared = DataManger()
    
    // 1. If we want to isolate any method/property from Actor we can mark it with - nonisolated
    nonisolated func getName() {
        //If we want to remove it from Actor class behaviour - nonisolated
        //This is NOT Async/await method if marked with - nonisolated
    }
    
    func fetchData() {
        //This is Actor - Async/Await default method
    }
}



//ViewModel Class
@Observable class GlobalActorsViewModel {
    
    // 2. If we want to make Actor-isolated method for synchronization or thread safety we can mark it with -  GlobalActor
    @MyAppGlobalActor func getData() {
        //This is marked with Global Actor so this method become part of DataManager Actor class Async method, we can call it ONLY await.
    }
}




//View
struct GlobalActorsView: View {
    @State var globalActorsVM = GlobalActorsViewModel()
    
    var body: some View {
        VStack {
            Text("Hello, world!")
        }
        .onAppear {
            Task {
                //This is Global Actor marked method, So we need to call it inside Async/Task{} with await.
                await globalActorsVM.getData()
            }
        }
    }
}




#Preview {
    GlobalActorsView()
}
