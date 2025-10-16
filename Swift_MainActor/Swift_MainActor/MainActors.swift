//
//  MainActorsView.swift
//  Swift_MainActor
//
//  Created by Ambreen Bano on 12/10/25.
//

import SwiftUI


//Data Manager/ Networking
class DataManager {
    static let shared = DataManager()
    private init(){}
    
    //This is Our Publisher
    @Published var dataPublisher: [String] = []
    
    func getData() async {
        //dataPublisher property is publisher and it publish values after 2sec
        dataPublisher.append("Apple")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        dataPublisher.append("Banana")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        dataPublisher.append("Orange")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        dataPublisher.append("Watermelon")
    }
}




// @MainActor - Only Class, Function, Property can be marked with @MainActor
// MainActor.run {} - Can be use to run block on main thread
// @MainActor in - Can be use to mark Task{} block to run on main thread


//View Model
// 1. Class can marked to run on @MainActor
@MainActor
@Observable class MainActorsViewModel {
    
    // 2. Property can marked to run on @MainActor
    @MainActor var dataArray: [String] = []
    
    init() { 
        initializeDataManger()
    }
    
    
    func initializeDataManger() {
       //@MainActor in - can be use to mark Task{} block to run on main thread
        Task { @MainActor in
            await DataManager.shared.getData()
            fetchData()
        }
    }
    
    
    // 3. Function can marked to run on @MainActor
    @MainActor
    func fetchData() { 
        dataArray = DataManager.shared.dataPublisher
    }
    
    
    func updateUI() async {
        //MainActor.run {} block can be use to run block on main thread
        await MainActor.run {
            dataArray.append("New Data Appended")
        }
    }
}



//View
struct MainActorsView: View {
    
    @State var mainActorsVM = MainActorsViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(mainActorsVM.dataArray, id: \.self) { data in
                    HStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text(data)
                    }
                }
                
            }
        }
    }
}




#Preview {
    MainActorsView()
}
