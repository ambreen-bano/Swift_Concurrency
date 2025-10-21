//
//  ContentView.swift
//  Swift_Refreshable
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
        fetchedDataArray.removeAll()
        //Suppose this is API Calling
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        fetchedDataArray.append(DataModel.init(name:"Apple"))
        fetchedDataArray.append(DataModel.init(name:"Banana"))
        fetchedDataArray.append(DataModel.init(name:"Orange"))
        fetchedDataArray.append(DataModel.init(name:"Watermelon"))
        fetchedDataArray = fetchedDataArray.shuffled()
    }
}



//MARK: ViewModel
// 1. If we marked class @MainActor then this VM will be on Main thread
@MainActor
@Observable class RefreshableViewModel {
    
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
struct RefreshableView: View {
    
    @State var refreshableVM = RefreshableViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(refreshableVM.dataModel) { data in
                    HStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text(data.name)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Fruits")
            .onAppear(perform: {
                refreshableVM.getData()
            })
            .onDisappear {
                //ON View .onDisappear{} we can cancell all task and no need to maintain weak/strong self
                refreshableVM.cancelAllTask()
            }
            .task {
                //We can call Async Task {} inside .task {} block then our task will automatically cancel when view will disappear and we don't need to manually call .cancel()
            }
            .refreshable {
                //.refreshable{} block is async, we can call whatever we want to call for View refresh
                //when we scroll down to refresh view, it showing default loader on UI
                refreshableVM.getData()
            }
        }
    }
}




#Preview {
    NavigationStack {
        RefreshableView()
    }
}
