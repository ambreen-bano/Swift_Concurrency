//
//  ContinuationsView.swift
//  Swift_Continuations
//
//  Created by Ambreen Bano on 11/10/25.
//

import SwiftUI

//Never forget to make VM as @MainActor
//Or After Async API calls update UI on MainActor.run {} block
//Don't forget when me are setting properties of the @observable or @published the it is going to update UI so, that property should be set on Main thread
// @MainActor  or MainActor.run {} - use with Async (Swift Concurrency)
// DispatchQueue.main.async - use with completion handlers (GCD)
// Don't mix "Swift Concurrency" with "GCD"


//View Model
@Observable class ContinuationsViewModel {
    
    var uiImage: UIImage?
    var imageName: String?
    
    let url = URL(string: "https://fastly.picsum.photos/id/20/3670/2462.jpg?hmac=CmQ0ln-k5ZqkdtLvVO23LjVAEabZQx2wOaT4pyeG10I")!
    
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data, let image = UIImage(data: data),
              let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    
    //MARK: API Call using Completion Handler function to Async Bridge
    
    //1. API Call using Completion Handler
    func fetchImageWithCompletionHandler(handler: @escaping (UIImage?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async { //If there is [weak self] in parent scope then no need to write again in child scope
                let image = self?.handleResponse(data: data, response: response)
                handler(image, error)
            }
        }.resume() //DON'T FORGET
    }
    
    
    
    //1. API Call using Async function and inside convert/Bridge Completion Handler OLD API CALL into Async
    @MainActor
    func fetchImageBridgeFromHandlerToAsync() async throws -> UIImage? {
        
        //This is bridge to convert completionhandler to async function
        //WE can convert with throwing or without throwing
        return try await withCheckedThrowingContinuation { continution in
            fetchImageWithCompletionHandler { image, error in
                
                //In any case if we are NOT RESUME continution.resume. Then, it is MEMORY LEAK.
                //We can ONLY resume it ONCE otherwise we will get errors
                //We need to resume it ONLY ONCE per condition or flow
                if let uiImage = image {
                    continution.resume(with: .success(uiImage))
                } else if let error = error {
                    continution.resume(with: .failure(error))
                } else {
                    continution.resume(throwing: URLError(.unknown))
                }
            }
        }
    }
    
    
    //MARK: Normal completion handler function to Async Bridge
    //2. Normal completion handler function
    func GetStringFromNormalHandler(handler: @escaping (String) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            handler("person")
        }
    }
    
    //2. Converting Normal Any completion handler into Async function
    //WE can convert with throwing or without throwing
    func GetStringBridgeCompletionHandlerToAsync() async -> String {
        return await withCheckedContinuation { continution in
            GetStringFromNormalHandler { name in
                continution.resume(returning: name)
            }
        }
    }
}





//View
struct ContinuationsView: View {
    
    @State var continuationsVM = ContinuationsViewModel()
    
    var body: some View {
        VStack {
            if let image = continuationsVM.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 300, height: 200)
            } else {
                Text("Hello, world!")
            }
            
            if let imageName = continuationsVM.imageName {
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 300, height: 200)
            }
        }
        .task {
            do {
                continuationsVM.uiImage = try await continuationsVM.fetchImageBridgeFromHandlerToAsync() //try because it is throwing
                continuationsVM.imageName = await continuationsVM.GetStringBridgeCompletionHandlerToAsync()  //No try because it is NOT throwing
            } catch {
                
            }
        }
    }
}




#Preview {
    ContinuationsView()
}
