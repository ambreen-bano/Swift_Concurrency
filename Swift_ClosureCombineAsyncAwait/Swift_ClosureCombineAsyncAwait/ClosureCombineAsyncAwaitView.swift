//
//  ClosureCombineAsyncAwaitView.swift
//  Swift_ClosureCombineAsyncAwait
//
//  Created by Ambreen Bano on 11/10/25.
//

import SwiftUI
import Combine


//Model
struct ImageModel {
    let image: UIImage?
}



//Network Manager
class NetworkManager {
    
    static let shared: NetworkManager = NetworkManager()
    private init(){ }
    let url = URL(string: "https://fastly.picsum.photos/id/20/3670/2462.jpg?hmac=CmQ0ln-k5ZqkdtLvVO23LjVAEabZQx2wOaT4pyeG10I")!
    
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data, let image = UIImage(data: data),
              let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    
    
    //1. API Call using Closure
    //Pass Completion Handler as parameter
    //Call Completion Handler when task is done
    //Issue - retain cycles if forget [weak self], no update if we forget to call completion handler in any all possible cases
    func fetchImageUsingClosure(completionHandler: @escaping (UIImage?, Error?) -> ()) {
        // @escaping is required for closure as it is using inside async function
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume() //If we are NOT calling this then this URLSession.shared.dataTask call will never start
    }
    
    
    //2. API Call using Combine
    //Return AnyPublisher when task is done
    func fetchImageUsingCombine() -> AnyPublisher<UIImage?, Error> {
        // @escaping is required for closure as it is using inside async function
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse) //To Transform data and response
            .mapError({$0}) //To Transform "AnyError" into "Error" Type
            .eraseToAnyPublisher() //To Erase publisher type to "AnyPublisher"
    }
    
    
    
    //3. API Call using Async/await
    //Return UIImage when task is done or throws error if failed
    //Clean/Readable/Safe way for API Calls
    func fetchImageUsingAsync() async throws -> UIImage? {
        do {
            //Whenever we are calling Async function we need to use await
            //await suspend the execution of next line of code
            //Async function can be call ONLY inside another Async function or Async block - Task{}
            let (data, response) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}




//ViewModel
@Observable class ClosureCombineAsyncAwaitViewModel {
    
    var imageModel: ImageModel?
    var cancellable: Set<AnyCancellable> = Set<AnyCancellable>() //This is required to store publishers until class is alive
    
    
    init() {
        //getImageUsingCompletionHandler()
        //getImageUsingCombine()
        Task {
            //Async function can be call ONLY inside another Async function or Async block - Task{}
            await getImageUsingAsync()
        }
    }
    
    
    //1. CompletionHandler
    func getImageUsingCompletionHandler(){
        NetworkManager.shared.fetchImageUsingClosure { [weak self] uiImage, error in
            //Need to use [weak self] to capture self weakly inside closeure to avoid retain cycle
            DispatchQueue.main.async { //Perform UI Update on Main Thread
                guard let self = self else { return }
                self.imageModel = ImageModel(image: uiImage)
            }
        }
    }
    
    
    //2. Combine
    func getImageUsingCombine() {
        NetworkManager.shared.fetchImageUsingCombine()
            .receive(on: DispatchQueue.main) //Perform UI Update on Main Thread - receive value on Main thread
            .sink { error in
                //Do Stuff If Error
            } receiveValue: { uiImage in
                self.imageModel = ImageModel(image: uiImage)
            }
            .store(in: &cancellable)
        
    }
    
    
    //3. Async/Await
    func getImageUsingAsync() async {
        //using try? we are avoiding to catch errors
        let uiImage = try? await NetworkManager.shared.fetchImageUsingAsync()
        await MainActor.run { //Perform UI Update on Main Thread
            self.imageModel = ImageModel(image: uiImage)
        }
    }
}




//View
struct ClosureCombineAsyncAwaitView: View {
    
    @State var closureCombineAsyncAwaitVM = ClosureCombineAsyncAwaitViewModel()
    
    var body: some View {
        VStack {
            if let uiImage = closureCombineAsyncAwaitVM.imageModel?.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .foregroundStyle(.purple)
                    .frame(width: 200, height: 200)
            } else {
                Text("No Image Data")
            }
        }
        .padding()
    }
}


#Preview {
    ClosureCombineAsyncAwaitView()
}
