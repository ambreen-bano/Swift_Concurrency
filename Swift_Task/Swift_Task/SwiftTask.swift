//
//  SwiftTask.swift
//  Swift_Task
//
//  Created by Ambreen Bano on 11/10/25.
//

import SwiftUI

//Task {} block can be execute on Main thread or can be on Background thread if we have not specify. System chooses on the basis of current scheduling


//My class is @MainActor so every thing will run on main thread except Async function which internally callls on Background threads
//URLSession.shared.data is automatically internally on background thread


//ViewModel
@MainActor
@Observable class SwiftTaskViewModel {
    
    var image1: UIImage?
    var image2: UIImage?
    var image3: UIImage?
    var imageFetchedTask: Task<Void,Never>? = nil
    
    let url = URL(string: "https://fastly.picsum.photos/id/20/3670/2462.jpg?hmac=CmQ0ln-k5ZqkdtLvVO23LjVAEabZQx2wOaT4pyeG10I")!
    
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data, let image = UIImage(data: data),
              let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    
    func fetchImage1() async throws {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let image = handleResponse(data: data, response: response)
            image1 = image
        } catch {
            throw error
        }
    }
    
    func fetchImage2() async throws {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let image = handleResponse(data: data, response: response)
            image2 = image
        } catch {
            throw error
        }
    }
    
    func fetchImageForCancellation() async throws {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let image = handleResponse(data: data, response: response)
            
            
            
            //Example 1: To check for task cancellation (This is just example but don't mix swift concurrency Async with GCD)
            //            DispatchQueue.global().async { [weak self] in
            //                var sum  = 0
            //                for _ in 0...50000000 {
            //
            //                    //Need to check Task is cancelled or not(ONLY .cancel() will not cancel task, it will just set isCancelled = true) -
            //                    //1. Task.isCancelled
            //                    //2. Task.isCancelled
            //                    if let imageFetchedTask = self?.imageFetchedTask, imageFetchedTask.isCancelled {
            //                        print("\n Task Cancelled....\n")
            //                        return //It will return from DispatchQueue.global() closure
            //                    }
            //
            //                    sum = sum + 1
            //                }
            //                print("\n Task Completed.....\n")
            //                DispatchQueue.main.async { [weak self] in
            //                    self?.image3 = image
            //                }
            //            }
            
            
//            //Example 2: To check for task cancellation using Task.isCancelled
//            try? await Task.sleep(nanoseconds: 5_000_000_000)
//            if Task.isCancelled { //check is isCancelled
//                print("\n Task Cancelled....\n")
//                return
//            } else {
//                print("\n Task Completed.....\n")
//                self.image3 = image
//            }
            
            
            //Example 3: To check for task cancellation using Task.checkCancellation()
            try await Task.sleep(nanoseconds: 5_000_000_000)
            try Task.checkCancellation() //call checkCancellation()
            print("\n Task Completed.....\n")
            self.image3 = image
            
            
            
        } catch {
            print("\n \(error.localizedDescription)...\n")
            throw error
        }
    }
}





//View
struct SwiftTask: View {
    
    @State var swiftTaskVM = SwiftTaskViewModel()
    
    var body: some View {
        VStack {
            if let image = swiftTaskVM.image1 {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            if let image = swiftTaskVM.image2 {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            
            NavigationLink("Task cancellation!", destination: SwiftTaskManualCancellation())
                .foregroundStyle(.purple)
            
            NavigationLink("Task Auto cancellation!", destination: SwiftTaskCancellationAutomatically())
                .foregroundStyle(.purple)
            
        }
        
        //This will call when view is appear on device
        .onAppear {
            //Below both Task{} block1 and Task{} block2 will execute concurrently
            //Task{} block2 is NOT waiting for Task{} block1 to complete
            
            //Task{} block1
            Task {
                //This Task{} block is Async block
                await sequentialTask()
                print("\n \(Thread.current) : \(Task.currentPriority)")
            }
            
            //Task{} block2
            Task {
                //This Task{} block is Async block
                try? await swiftTaskVM.fetchImage1()
                print("\n \(Thread.current) : \(Task.currentPriority)")
            }
            
            
            
            
            
            //All below Task{} will run concurrenctly but with different priority
            //We can give Task priority
            Task(priority: .high) {
                //This Task{} block is Async block
                try? await swiftTaskVM.fetchImage1()
                print("\n High : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .userInitiated) {
                //This Task{} block is Async block
                try? await swiftTaskVM.fetchImage1()
                print("\n userInitiated : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .medium) {
                //This Task{} block is Async block
                try? await swiftTaskVM.fetchImage1()
                print("\n medium : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .utility) {
                //This Task{} block is Async block
                try? await swiftTaskVM.fetchImage1()
                print("\n utility : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .low) {
                //This Task{} block is Async block
                try? await swiftTaskVM.fetchImage1()
                print("\n low : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .background) {
                //This Task{} block is Async block
                try? await swiftTaskVM.fetchImage1()
                print("\n background : \(Thread.current) : \(Task.currentPriority)")
            }
            
            
            
            
            
            //Child Task{} inherit properties of the Parent Task{}
            //Child task will have same priority as Parent Task. If not specifying
            Task(priority: .low) {
                try? await swiftTaskVM.fetchImage1()
                print("Parent Task1: \(Thread.current) : \(Task.currentPriority)")
                
                Task {
                    try? await swiftTaskVM.fetchImage1()
                    print("Child Task1: \(Thread.current) : \(Task.currentPriority)")
                }
            }
            
            
            //Child Task{} is detached from Parent Then Child will NOT inherit properties of the Parent Task{}
            //Detached Child task priority is chooses by SYSTEM If not specify
            //Detached Child task will execute independently from Parent
            Task(priority: .low) {
                try? await swiftTaskVM.fetchImage1()
                print("Parent Task2: \(Thread.current) : \(Task.currentPriority)")
                
                Task.detached {
                    try? await swiftTaskVM.fetchImage1()
                    print("Detached Child Task2: \(Thread.current) : \(Task.currentPriority)")
                }
            }
        }
    }
    
    
    func sequentialTask() async {
        //Below both await will execute in sequentially
        //swiftTaskVM.fetchImage2 will start executing once swiftTaskVM.fetchImage1 is completed
        try? await swiftTaskVM.fetchImage1()
        try? await swiftTaskVM.fetchImage2()
    }
}




//Manual task cancellation .cancel() in .onDisappear
struct SwiftTaskManualCancellation: View {
    
    @State var swiftTaskVM = SwiftTaskViewModel()
    
    var body: some View {
        VStack {
            if let image = swiftTaskVM.image3 {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
        }
        .onAppear {
            //If View is disappear then we need to cancel Async task
            //For cancelling any task we need to call .cancel()
            //Cancel the task when response is not require, good for optimization
            swiftTaskVM.imageFetchedTask = Task {
                try? await swiftTaskVM.fetchImageForCancellation()
                print("Task 1 : \(Thread.current) : \(Task.currentPriority)")
            }
        }
        .onDisappear {
            //When view is disappear then we don't need to continue task and we need to cancel it.
            swiftTaskVM.imageFetchedTask?.cancel()
        }
    }
}




//Auto task cancellation using .task{} block
struct SwiftTaskCancellationAutomatically: View {
    
    @State var swiftTaskVM = SwiftTaskViewModel()
    
    var body: some View {
        VStack {
            if let image = swiftTaskVM.image3 {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            //This is structured Task
            //Calls once per instance
            //WE can have multiple .task{}
            //We can auto restart task if id: changes .task(id: taskID){}
            //This is for Async task or API Calls
            //This .task{} block will automatically cancel task if view disappear. No need to manually call .cancel()
            try? await swiftTaskVM.fetchImageForCancellation()
            print("Task 2: \(Thread.current) : \(Task.currentPriority)")
        }
    }
}




#Preview {
    SwiftTask()
}
