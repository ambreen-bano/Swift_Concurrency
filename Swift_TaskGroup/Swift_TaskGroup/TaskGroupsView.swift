//
//  ContentView.swift
//  Swift_TaskGroup
//
//  Created by Ambreen Bano on 11/10/25.
//

import SwiftUI

//Structured concurrency - .task{}, async/await, TaskGroup{}
//In Structured concurrency if parent task cancel then automatically it's all child task will cancel
//Structured concurrency - child task is tied automatically with parent task, no orphan child task

//.task{} - SwiftUI cancels PARENT task automatically on view disappearance
//So, using self in child task is safe.
//If view is disappear -> Then Parent Task Cancel -> Then Auto Child Task cancel

//GCD - UnStructured concurrency - child is NOT tied automatically with parent task



//View Model
@Observable class TaskGroupsViewModel {
    
    var images: [UIImage] = []
    let url = URL(string: "https://fastly.picsum.photos/id/20/3670/2462.jpg?hmac=CmQ0ln-k5ZqkdtLvVO23LjVAEabZQx2wOaT4pyeG10I")!
    
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data, let image = UIImage(data: data),
              let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    //Single API Call
    func fetchImage(_ url: URL) async throws -> UIImage {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let image = handleResponse(data: data, response: response) {
                try? await Task.sleep(nanoseconds: 1_000_000_000) //MOCK delay for testing
                return image
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw error
        }
    }
    
    
    
    //Multiple Async Calls using async let for concurrent API calls (good to use for 2 - 4 calls)
    //If the parent task is cancel then all the async child task will auto cancel
    func fetchImagesUsingAsyncLet() async throws {
        //ALL BELOW ARE CHILD TASK
        async let fetchImage1 = fetchImage(url)
        async let fetchImage2 = fetchImage(url)
        async let fetchImage3 = fetchImage(url)
        
        let (image1, image2, image3) = try await (fetchImage1, fetchImage2, fetchImage3)
        images.append(contentsOf: [image1, image2, image3])
    }
    
    
    //Multiple Async Calls using TaskGroup for concurrent API calls (good to use for 10-20 calls)
    func fetchImagesUsingTaskGroup() async throws {
        
        //UIImage.self - return type should be same as return type of the child async calls
        try await withThrowingTaskGroup(of: UIImage.self) { group in
            
            var responseImages: [UIImage] = []
            //add child task in group using addTask{}
            //If any child task throw, all other task will cancel
            //If the parent task is cancel then all the task group child task will auto cancel
            //ALL BELOW ARE CHILD TASK
            group.addTask {
                try await self.fetchImage(self.url)
            }
            group.addTask {
                try await self.fetchImage(self.url)
            }
            group.addTask {
                //.task{} - SwiftUI cancels PARENT task automatically on view disappearance
                //So, using self in child task is safe.
                //If view is disappear -> Then Parent Task Cancel -> Then Auto Child Task cancel
                try await self.fetchImage(self.url)
            }
            
            //"await" to get all the ouput of the async calls from group
            //sequence of the ouput response is NOT ordered
            //whoever async call is completed first will get that first from group
            for try await image in group {
                responseImages.append(image)
            }
            
            images = responseImages //assign all at once as images is observable property to re-render view
        }
    }
    
    func fetchImagesUsingTaskGroupOPTIMIZE() async throws {
        
        //UIImage.self - return type should be same as return type of the child async calls
        try await withThrowingTaskGroup(of: UIImage.self) { group in
            
            let urls: [URL] = [url, url, url] //In actual app urls will be different
            var responseImages: [UIImage] = []
            
            //We know how many async calls we have so we can reserveCapacity with count - OPTIMIZE
            responseImages.reserveCapacity(urls.count)
            
            //we can loop on urls to add child task - OPTIMIZE
            for url in urls {
                group.addTask {
                    try await self.fetchImage(url)
                }
            }
            
            for try await image in group {
                responseImages.append(image)
            }
            
            images = responseImages //assign all at once as images is observable property to re-render view
        }
    }
}




//View
struct TaskGroupsView: View {
    
    @State var taskGroupsVM = TaskGroupsViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(taskGroupsVM.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 300, height: 200)
                }
            }
        }
        .task {

            do {
                
                //This is PARENT TASK------
                
                //Multiple concurrent Async Calls using "async let"
                //try await taskGroupsVM.fetchImagesUsingAsyncLet()
                
                //Multiple concurrent Async Calls using withThrowingTaskGroup{}
                //try await taskGroupsVM.fetchImagesUsingTaskGroup()
                try await taskGroupsVM.fetchImagesUsingTaskGroupOPTIMIZE()
                
            } catch {  }
        }
    }
}


#Preview {
    TaskGroupsView()
}
