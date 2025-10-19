//
//  AsyncPublisher.swift.swift
//  Swift_AsyncPublisher
//
//  Created by Ambreen Bano on 12/10/25.
//

import SwiftUI
import Combine


//MARK: Async Way To Handle AsyncData using ACTOR publisher and publisher.VALUES
//Actor - Data Manager/ Networking
//This is Async way to handle Async data
actor ActorDataManager {
    static let shared = ActorDataManager()
    private init(){}
    
    //This is Our Publisher
    @Published var dataPublisher: [String] = []
    
    func getData() async {
        //dataPublisher property is publisher and it publish values after 2sec
        dataPublisher.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        dataPublisher.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        dataPublisher.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        dataPublisher.append("Watermelon")
    }
}




//MARK: combine Way To Handle AsyncData using CLASS publisher and publisher.SINK
//Class - Data Manager/ Networking
//This is Combine way to handle Async data
class DataManager {
    static let shared = DataManager()
    private init(){}
    
    //This is Our Publisher
    @Published var dataPublisher: [String] = []
    
    func getData() async {
        //dataPublisher property is publisher and it publish values after 2sec
        dataPublisher.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        dataPublisher.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        dataPublisher.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        dataPublisher.append("Watermelon")
    }
}




//View Model
@Observable class AsyncPublisherViewModel {
    // In @Observable class all properties are by default publishers
    var dataArray: [String] = []
    var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init() {
        //combineWayToHandleAsyncData()
        asyncWayToHandleAsyncData()
    }
    
    
    
    
    //MARK: combine Way To Handle AsyncData using CLASS publisher and publisher.SINK
    func combineWayToHandleAsyncData(){
        Task {
            await DataManager.shared.getData()
        }
        //We are adding subscriber to the DataManager publisher
        addSubscriber()
    }
    
    func addSubscriber() {
        //We are going to subcribe DataManager publisher property
        //Publisher is publishing value after 2sec delays and out VM dataArray property is getting updated and then whenever our dataArray is updated, our view is updated as VM (dataArray is VM property) is observable
        DataManager.shared.$dataPublisher.sink { array in
            self.dataArray = array
        }
        .store(in: &cancellable)
    }
    
    
    
    
    
    //MARK: Async Way To Handle AsyncData using ACTOR publisher and publisher.VALUES
    func asyncWayToHandleAsyncData(){
        Task {
            await ActorDataManager.shared.getData()
        }
        //We are adding listening to the ActorDataManager publisher
        addListenerToAsyncPublisher()
    }
    
    func addListenerToAsyncPublisher() {
        Task {
    
            //using .values we can listen publisher values
            for await value in await ActorDataManager.shared.$dataPublisher.values {
                //This for loop will always wait to receive publisher value
                dataArray = value
            }
            //IF WE WRITE ANY CODE AT THIS LINE. THEN, IT WILL NOT EXECUTE BECAUSE "FOR AWAIT" WILL ALWAYS WAIT FOR THE VALUES PUBLISH BY PUBLISHER
            print("This will NOT execute") //THIS WILL NOT EXECUTE (ONLY IT IS POSSIBLE TO EXECUTE. If we use break inside for-loop)
        }
        
        Task {
            //IF WANT TO EXECUTE SOMETHING ASYNC. SO, WE CAN WRITE HERE IN SEPARATE TASK{} BLOCK
            print("This will execute")
            
            //with AsyncPublisher .values we can use .map .dropFirst() etc.
            //await ActorDataManager.shared.$dataPublisher.values.dropFirst()
        }
    }
}





//View
struct AsyncPublisher: View {
    
    @State var asyncPublisherVM = AsyncPublisherViewModel() //at this line it calls it's init()
    
    var body: some View {
        VStack {
            List {
                ForEach(asyncPublisherVM.dataArray, id: \.self) { data in
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
    AsyncPublisher()
}
