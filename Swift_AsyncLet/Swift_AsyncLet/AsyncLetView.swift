//
//  AsyncLetView.swift
//  Swift_AsyncLet
//
//  Created by Ambreen Bano on 11/10/25.
//

import SwiftUI


//View Model
@Observable class AsyncLetViewModel {
    
    var imagesArray: [UIImage] = []
    
    let url = URL(string: "https://fastly.picsum.photos/id/20/3670/2462.jpg?hmac=CmQ0ln-k5ZqkdtLvVO23LjVAEabZQx2wOaT4pyeG10I")!
    
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data, let image = UIImage(data: data),
              let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    func fetchImages() async throws -> UIImage {
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
}




//View
//CONCURRENT calls using "async/await"
struct AsyncAwaitSequentialCallsView: View {
    
    @State var asyncLetVM = AsyncLetViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(asyncLetVM.imagesArray, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 300, height: 200)
                }
            }
            .frame(alignment: .center)
        }
        .onAppear {
            
            let taskIfWantToCancel = Task {
                do {
                    //All will execute in sequential manner one after the another
                    //image2 call will start when image1 is completed. image3 will start when image2 is completed
                    let image1 = try await asyncLetVM.fetchImages()
                    asyncLetVM.imagesArray.append(image1)
                    let image2 = try await asyncLetVM.fetchImages()
                    asyncLetVM.imagesArray.append(image2)
                    let image3 = try await asyncLetVM.fetchImages()
                    asyncLetVM.imagesArray.append(image3)
                } catch {
                    
                }
            }
        }
    }
}


//CONCURRENT Calls using multiple "Task{}" blocks
struct AsyncAwaitConcurrentCallsView: View {
    
    @State var asyncLetVM = AsyncLetViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(asyncLetVM.imagesArray, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 300, height: 200)
                }
            }
            .frame(alignment: .center)
        }
        .onAppear {
            
            //NOT READABLE CODE with this approach ----
            //All image1/image2/image3 calls will execute in concurrently as all Task block1/block2/block3 will execute concurrently
            //For Cancellation we need to keep track of all task blocks and need to cancel all.
            
            //Task Block1
            let task1IfWantToCancel = Task {
                do {
                    let image1 = try await asyncLetVM.fetchImages()
                    asyncLetVM.imagesArray.append(image1)
                } catch {
                    
                }
            }
            
            //Task Block2
            let task2IfWantToCancel = Task {
                do {
                    let image2 = try await asyncLetVM.fetchImages()
                    asyncLetVM.imagesArray.append(image2)
                } catch {
                    
                }
            }
            
            
            //Task Block3
            let task3IfWantToCancel = Task {
                do {
                    let image3 = try await asyncLetVM.fetchImages()
                    asyncLetVM.imagesArray.append(image3)
                } catch {
                    
                }
            }
        }
    }
}


//CONCURRENT Calls using "async let"
//Clean and Readable code using "async let"
//GOOD to use when we have 2 - 3 Async API calls
//If we have many Async API Calls. Then, use TaskGroup {}
struct AsyncLetConcurrentCallsView: View {
    
    @State var asyncLetVM = AsyncLetViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(asyncLetVM.imagesArray, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 300, height: 200)
                }
            }
            .frame(alignment: .center)
        }
        .onAppear {
            
            Task {
                do {
                    //Using async let - All will execute in CONCURRENT manner, All will start executing at the same time
                    async let fetchImage1 = asyncLetVM.fetchImages()
                    async let fetchImage2 = asyncLetVM.fetchImages()
                    async let fetchImage3 = asyncLetVM.fetchImages()
                    
                    //Then we are waiting await to complete all the async calls to get all image data
                    let (image1, image2, image3) = try await (fetchImage1, fetchImage2, fetchImage3)
                    asyncLetVM.imagesArray.append(contentsOf: [image1, image2, image3])
                } catch {
                    
                }
            }
        }
    }
}



#Preview {
    AsyncAwaitSequentialCallsView()
//    AsyncAwaitConcurrentCallsView()
//    AsyncLetConcurrentCallsView()
}
