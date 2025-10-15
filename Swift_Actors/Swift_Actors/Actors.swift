//
//  ContentView.swift
//  Swift_Actors
//
//  Created by Ambreen Bano on 12/10/25.
//

import SwiftUI


//To check Thread issues Enable Thread Sanitizer
//Go to Edit Scheme -> Run -> Diagnostics -> Thread Sanitizer


//Problem - Race Condition in Multi thread environment
//Shared Class are not thread safe
//Solutions -
//1. Before Actor we use  queue to queueing all task to execute one after another on a queue
//2. Actor is providing auto thread safe class (Actor isolated) as it will ask "await" to call before access any async functions/properties of the actor class (Bydefault all is async in Actor)



//MARK: Shared Class - Actor for thread safe
//Singleton class, Multiple threads can access same instance  - NOT THREAD SAFE
//Thread 1 and Thread 2 both Modifying DataManager property
actor DataManagerActor {
    
    static let shared: DataManagerActor = DataManagerActor() //singleton class, all thread will access same instance
    private init() {}
    
    private var dataArray: [Int] = [0,1,2]
    
    
    //Functions of Actor class are "async" by default and require to call with "await" inside async function or Task{} block
    func getRandomData() -> Int {
        let randomInt = Int.random(in: 1...5000)
        dataArray.append(randomInt) //Writing in dataArray property
        print(Thread.current)
        return dataArray.randomElement() ?? 0
    }
    
    
    //Inside Actor if we want something to make non Actor then we need to mark it as "nonisolated"
    //"nonisolated" functions are not "async" by default like other functions of Actor class
    //To call "nonisolated" functions it doesn't require async function or Task{} block
    //To call "nonisolated" functions it doesn't require "await"
    nonisolated func getTitle() -> String {
        return "Title from Actor, Non-isolated function"
    }
}




//MARK: Shared Class - Thread safe using Queue
//Singleton class, Multiple threads can access same instance  - NOT THREAD SAFE
//MAKE THREAD SAFE CLASS - USING QUEUE - We are queue all access to the function inside single queue. So, multiple thread can send request to access function. But all will execute on a single queue one after the another to avoid race condition.
//In myThreadSafeQueue queue task are waiting to execute for previous task (or running task) to complete on the same queue
class DataManagerThreadSafeClass {
    
    static let shared: DataManagerThreadSafeClass = DataManagerThreadSafeClass()
    private init() {}
    
    private var dataArray: [Int] = [0,1,2]
    
    //All modification request will queue inside myThreadSafeQueue to execute to avoid race condition
    //Write task perform inside single queue to avoid race condition and making it thread safe class
    //This is a one way to make class thread safe
    private var myThreadSafeQueue = DispatchQueue(label: "MyThreadSafeQueue")
    
    func getRandomData(handler: @escaping (Int) -> Void) {
        //All modification request will queue inside myThreadSafeQueue to execute to avoid race condition
        myThreadSafeQueue.async { [weak self] in
            let randomInt = Int.random(in: 1...5000)
            self?.dataArray.append(randomInt) //Writing in dataArray property
            print(Thread.current)
            handler(self?.dataArray.randomElement() ?? 0)
        }
    }
}



//MARK: Shared Class - Not thread safe
//Singleton class, Multiple threads can access same instance  - NOT THREAD SAFE
//Thread 1 and Thread 2 both Modifying DataManager property
class DataManager {
    
    static let shared: DataManager = DataManager() //singleton class, all thread will access same instance
    private init() {}
    
    private var dataArray: [Int] = [0,1,2]
    
    func getRandomData() -> Int {
        
        //This method can be called by multiple threads to modifying dataArray can cause race condition - CLASS IS NOT THREAD SAFE
        let randomInt = Int.random(in: 1...5000)
        dataArray.append(randomInt) //Writing in dataArray property
        print(Thread.current)
        return dataArray.randomElement() ?? 0
    }
}



struct HomeView: View {
    
    //timer publisher - publish at every 0.1sec
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var text = 0
    @State var title = ""
    
    var body: some View {
        VStack {
            Text("Home Screen")
            Text(title)
            Text("\(text)")
        }
        .bold()
        .padding()
        .onReceive(timer) { value in
            DispatchQueue.global(qos: .utility).async {
                //Thread 1 : Modifying DataManager property
                //[weak self] - NO need to use here as it is inside Struct
                
                //Access is NOT Thread Safe
                //text = DataManager.shared.getRandomData()
                
                //Access is Thread Safe using Single Queue
                //DataManagerThreadSafeClass.shared.getRandomData { randomData in
                //    text = randomData
                //}
            }
            
            Task {
                //Access is Thread Safe using Actor
                text = await DataManagerActor.shared.getRandomData()
            }
            
            //DO NOT NEED to call inside Async functions or Task{} block
            //DO NOT NEED "AWAIT" to call nonisolated functions
            title = DataManagerActor.shared.getTitle()
        }
    }
}



struct ProfileView: View {
    
    //timer publisher - publish at every 0.01sec
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var text = 0
    @State var title = ""
    
    var body: some View {
        VStack {
            Text("Profile Screen")
            Text(title)
            Text("\(text)")
        }
        .bold()
        .padding()
        .onReceive(timer) { value in
            DispatchQueue.global(qos: .background).async {
                //Thread 2 : Modifying DataManager property
                
                //Access is NOT Thread Safe
                //text = DataManager.shared.getRandomData()
                
                //Access is Thread Safe using single Queue
                //DataManagerThreadSafeClass.shared.getRandomData { randomData in
                //    text = randomData
                //}
            }
            
            
            Task {
                //Access is Thread Safe using Actor
                text = await DataManagerActor.shared.getRandomData()
            }
            
            //DO NOT NEED to call inside Async functions or Task{} block
            //DO NOT NEED "AWAIT" to call nonisolated functions
            title = DataManagerActor.shared.getTitle()
        }
    }
}


struct ActorsView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("Home")
                    }
                }.tag(0)
            
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                }.tag(1)
        }
    }
}


#Preview {
    ActorsView()
}
