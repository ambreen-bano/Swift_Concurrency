//
//  ContentView.swift
//  Swift_StrongWeakWithAsyncAwait
//
//  Created by Ambreen Bano on 12/10/25.
//

import SwiftUI


//Data Manager/ Networking
class DataManager {
    static let shared = DataManager()
    private init(){}
    
    var fetchedDataArray: [String] = []
    
    func fetchedData() async {
        fetchedDataArray.append("Apple")
    }
}



//View Model
@MainActor
@Observable class StronWeakWithAsyncAwaitViewModel {
    
    var dataArray: [String] = []
    
    //Void is Success data, Never is Error case
    //On Succeess cases we are returning Void
    //On Failure cases we are saying Error Never occurred
    var myTask1: Task<Void, Never>? = nil
    var myAllTask: [Task<Void, Never>?] = []
    
    
    func getData1() {
        //1. This is Strong Reference
        Task {
            await DataManager.shared.fetchedData()
            dataArray = DataManager.shared.fetchedDataArray
        }
    }
    
    
    func getData2() {
        //2. This is Strong Reference
        Task {
            await DataManager.shared.fetchedData()
            self.dataArray = DataManager.shared.fetchedDataArray
        }
    }
    
    
    func getData3() {
        //3. This is Strong Reference
        Task { [self] in
            await DataManager.shared.fetchedData()
            self.dataArray = DataManager.shared.fetchedDataArray
        }
    }
    
    
    func getData4() {
        //4. This is Weak Reference
        Task { [weak self] in
            if let self = self {
                await DataManager.shared.fetchedData()
                self.dataArray = DataManager.shared.fetchedDataArray
            }
        }
    }

    
    func getData5() {
        //5. We DON'T NEED to write these strong/weak references because we can cancel task -
        //Cancel this myTask1 onDisappear {}
        myTask1 = Task { [weak self] in
            if let self = self {
                await DataManager.shared.fetchedData()
                self.dataArray = DataManager.shared.fetchedDataArray
            }
        }
    }
    
    
    func getData6() {
        //6. If we have multiple Task{} in class, we can cancel all -
        //Cancel this myTask1 onDisappear {}
        let myTask_1 = Task { [weak self] in
            if let self = self {
                await DataManager.shared.fetchedData()
                self.dataArray = DataManager.shared.fetchedDataArray
            }
        }
        myAllTask.append(myTask_1)
        
        let myTask_2 = Task { [weak self] in
            if let self = self {
                await DataManager.shared.fetchedData()
                self.dataArray = DataManager.shared.fetchedDataArray
            }
        }
        myAllTask.append(myTask_2)
        
        let myTask_3 = Task { [weak self] in
            if let self = self {
                await DataManager.shared.fetchedData()
                self.dataArray = DataManager.shared.fetchedDataArray
            }
        }
        myAllTask.append(myTask_3)
    }
    
    
    //We have multiple Task{} in class, we can cancel all
    func cancelAllTask() {
        myAllTask.forEach{ $0?.cancel() }
        myAllTask = []
    }
}



//View
struct StronWeakWithAsyncAwaitView: View {
    
    @State var stronWeakWithAsyncAwaitVM = StronWeakWithAsyncAwaitViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(stronWeakWithAsyncAwaitVM.dataArray, id: \.self) { data in
                    HStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text(data)
                    }
                }
            }
            .onAppear(perform: {
                stronWeakWithAsyncAwaitVM.getData1()
            })
            .onDisappear {
                //ON View .onDisappear{} we can cancell all task and no need to maintain weak/strong self
                stronWeakWithAsyncAwaitVM.myTask1?.cancel()
                stronWeakWithAsyncAwaitVM.cancelAllTask()
            }
            .task {
                //We can call Async Task {} inside .task {} block then our task will automatically cancel when view will disappear and we don't need to manually call .cancel()
            }
        }
    }
}




#Preview {
    StronWeakWithAsyncAwaitView()
}
