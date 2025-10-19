//
//  AsyncStreams.swift
//  Swift_AsyncStream
//
//  Created by Ambreen Bano on 13/10/25.
//

import SwiftUI


//MARK: Bridges to convert old way to New Async/Await
//withCheckedContinuation (handle single callback) - Bridge to Convert Old way completion handler to Async/await
//AsyncStream (handle Multiple callback) - Bridge to Convert Old way multiple completion handler calls to Async/await



class DataManager {
    static let shared = DataManager()
    private init(){}
    
    //1. Old Way
    //Mocking Async data streams (multiple values asyncrounsly, handler will call multiple times asyncrounsly)
    func getNumbers(
        completionHandler: @escaping (Int) -> Void,
        onFinish: @escaping (Error?) -> Void) {
            let numbers = [1,2,3,4,5,6,7,8,9,10]
            for numb in numbers {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(numb)) {
                    completionHandler(numb)
                    if numb == numbers.last {
                     onFinish(nil)
                    }
                }
            }
        }
    
    
    //2. New Way using Async/await - AsyncStream
    //Bridge -  To Convert Old way to Async/await swift concurrency using AsyncStream
    //AsyncStream listening like we have subscriber with publisher in combine
    func getAsyncStream() -> AsyncStream<Int> {
        return AsyncStream { continution in
            getNumbers { numb in
                continution.yield(numb)
            } onFinish: { error in
                continution.finish()
            }

        }
    }
}



@Observable class AsyncStreamsViewModel {
    @MainActor var currentNumber: Int = 0
    
    //1. Old Way
    @MainActor
    func getNumbersUsingCompletionHandler() {
        DataManager.shared.getNumbers { [weak self] numb in
            self?.currentNumber = numb
        } onFinish: { error in
            if let error = error {
                print("\(error) Occurred")
            }
        }
    }
    
    
    //2. New Way using Async/await
    @MainActor
    func getNumbersUsingAsyncAwait() {
        //Life of myTask is different from getNumbers() GCD. If we cancel myTask then only myTask will stop and GCD will continue calling completionHandlers
        let myTask = Task {
            //Using For-await we are listening AsyncStream
            for await numb in DataManager.shared.getAsyncStream() {
                currentNumber = numb
            }
            
            //We can use some predefine operators like dropFirst(count) etc.
            //for await numb in DataManager.shared.getAsyncStream().dropFirst(2) {
            //    currentNumber = numb
            //}
        }
    }
}



struct AsyncStreamsView: View {
    
    @State var asyncStreamsVM = AsyncStreamsViewModel()
    
    var body: some View {
        VStack {
            Text("\(asyncStreamsVM.currentNumber)")
                .bold()
                .font(.largeTitle)
        }
        .onAppear {
            //1. Old Way
            //asyncStreamsVM.getNumbersUsingCompletionHandler()
            
            //2. New Way using Async/await
            asyncStreamsVM.getNumbersUsingAsyncAwait()
        }
    }
}

#Preview {
    AsyncStreamsView()
}
