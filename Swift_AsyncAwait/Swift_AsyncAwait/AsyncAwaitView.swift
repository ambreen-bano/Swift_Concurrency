//
//  AsyncAwaitView.swift
//  Swift_AsyncAwait
//
//  Created by Ambreen Bano on 11/10/25.
//

import SwiftUI

//DispatchQueue/Task/MainActor.run/@MainActor - indicates thread switching
//Async/await doesn't indicate it is Main thread or background thread

//"Async" Function can be call ONLY inside another "Async" function or inside Task {} block
//"await" is require to call any "Async" function
//"await" means it will suspend the code to execute next line of code untill "Async" function is completed.
//Multiple "await" then it will call all "Async" functions in SEQUENTIAL manner

//non-@MainActor "async" functions can run on any thread.
//The SYSTEM CHOOSES based on runtime scheduling (can be Main/Background).
//Task {} block can be execute on Main thread or can be on Background thread if we have not specify. System chooses on the basis of current scheduling

//View Model
@Observable class AsyncAwaitViewModel {
    
    var titleArray:[String] = []
    
    func getThreads(){
        
        //MAIN Thread
        titleArray.append("Thread 1 = \(Thread.current)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            //MAIN Thread
            self?.titleArray.append("Thread 2 = \(Thread.current)")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 4) { [weak self] in
            //BACKGROUND Thread
            self?.titleArray.append("Thread 3 = \(Thread.current)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                //MAIN Thread
                self?.titleArray.append("Thread 4 = \(Thread.current)")
            }
        }
        
        
        //Task {} block can be execute on Main thread or can be on Background thread if we have not specify. System chooses on the basis of current scheduling
        //Using Task Block
        Task {
            //await is require to call any Async function
            //await is suspend the code to execute next line of code
            //Below all functions are Async And all are executing in sequencial because of await
            await getAuther1()
            await getAuther2()
            await getAuther3()
            
            await getAuther6()
        }
    }
    
    
    func getAuther1() async {
        titleArray.append("Auther 1 = \(Thread.current)")
    }
    
    func getAuther2() async {
        await MainActor.run {
            //This BLOCK will execute on MAIN thread
            titleArray.append("Auther 2 = \(Thread.current)")
        }
    }
    
    @MainActor //This FUNCTION will execute on Main thread
    func getAuther3() async {
        titleArray.append("Auther 3 = \(Thread.current)")
        await getAuther4()
        //Function is on MAIN thread. So if there is any Async/await BACKGROUND call. Then, thread will switch to BACKGROUND to execute that async function. Once await is completed the async function call. Then, thread will switch to MAIN Thread again to execute next lines of code.
        titleArray.append("Auther 5 = \(Thread.current)")
    }
    
    
    func getAuther4() async {
        //non-@MainActor "async" functions can run on any thread.
        //The SYSTEM CHOOSES based on runtime scheduling (can be Main/Background).
        titleArray.append("Auther 4 = \(Thread.current)")
    }
    
    
    @MainActor
    func getAuther6() async {
        //Function is on MAIN thread. So if there is any Async/await BACKGROUND call. Then, thread will switch to BACKGROUND to execute that async function. Once await is completed the async function call. Then, thread will switch to MAIN Thread again to execute next lines of code.
        try? await Task.sleep(nanoseconds: 10000000000) //This execute on background thread internally
        titleArray.append("Auther 6 = \(Thread.current)")
    }
}




//View
struct AsyncAwaitView: View {
    
    @State var asyncAwaitVM = AsyncAwaitViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(asyncAwaitVM.titleArray, id: \.self) { title in
                    Text(title)
                        .padding()
                }
            }
        }
        .onAppear {
            asyncAwaitVM.getThreads()
        }
    }
}




#Preview {
    AsyncAwaitView()
}
