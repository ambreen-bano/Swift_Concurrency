//
//  ContentView.swift
//  Swift_AsyncAwaitWithMVVM
//
//  Created by Ambreen Bano on 12/10/25.
//


import SwiftUI

//MARK: Model
struct DataModel : Identifiable {
    let id = UUID().uuidString
    let name: String
}

//Data Manager/ Networking
class DataManager {
    static let shared = DataManager()
    private init(){}
    
    var fetchedDataArray: [DataModel] = []
    
    func fetchingData() async {
        //Suppose this is API Calling
        fetchedDataArray.append(DataModel.init(name:"Apple"))
        fetchedDataArray.append(DataModel.init(name:"Banana"))
        fetchedDataArray.append(DataModel.init(name:"Orange"))
    }
}



//MARK: ViewModel
// 1. If we marked class @MainActor then this VM will be on Main thread
@MainActor
@Observable class AsyncAwaitWithMVVMViewModel {
    
    var dataModel: [DataModel] = []
    var myAllTask: [Task<Void, Never>?] = []
    
    
    // 2. We can mark function @MainActor to execute that function on Main thread
    //await DataManager.shared.fetchingData() this is API call which will internally call on BG thread, Once await is completed then function switch back to main thread to execute next lines of code
    @MainActor
    func getData() {
        // 3. Avoid creating Task{} block in View to keep View clean
        //Use Task {} block in VM to keep View clean
        let myTask = Task {
            await DataManager.shared.fetchingData() //API Call on Background thread
            dataModel = DataManager.shared.fetchedDataArray
        }
        myAllTask.append(myTask)
    }
    
    
    
    // 4. All Task Cancellation handle in VM
    //We have multiple Task{} in class, we can cancel all
    func cancelAllTask() {
        myAllTask.forEach{ $0?.cancel() }
    }
}



//MARK: View
// 5. There is No Async or Task{} blocks inside View, Our View is clean and readable
struct AsyncAwaitWithMVVMView: View {
    
    @State var asyncAwaitWithMVVMVM = AsyncAwaitWithMVVMViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(asyncAwaitWithMVVMVM.dataModel) { data in
                    HStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text(data.name)
                    }
                }
            }
            .onAppear(perform: {
                asyncAwaitWithMVVMVM.getData()
            })
            .onDisappear {
                //ON View .onDisappear{} we can cancell all task and no need to maintain weak/strong self
                asyncAwaitWithMVVMVM.cancelAllTask()
            }
            .task {
                //We can call Async Task {} inside .task {} block then our task will automatically cancel when view will disappear and we don't need to manually call .cancel()
            }
        }
    }
}




#Preview {
    AsyncAwaitWithMVVMView()
}
