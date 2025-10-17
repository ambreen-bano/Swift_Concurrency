//
//  StructClassActorView.swift
//  Swift_StructClassActor
//
//  Created by Ambreen Bano on 12/10/25.
//

import SwiftUI

//VALUE TYPE------
//Struct, Enum, Int, String, Float, Protocols etc.
//Store in STACK (data value store directly in stack)



//REFERENCE TYPE------
//Class, Functions, Closures, Actors, Protocols(:AnyClass or : AnyObject)
//Store in HEAP (data value )



//STRUCT------
//Value type - Copying data
//Faster - Because Copying data so, no sync is required with other references
//Default Init
//Mutating kw required
//NO Inheritance
//Store in - Stack
//Thread Safe - Each thread has OWN separate Stack (No shared stack)
//NO ARC(Automatic reference counting)
//In struct when we modify property me are creating new completly new Struct because it is value type so it create copy




//CLASS------
//Reference type - Copying reference/Address
//Slower - Because Copying reference/Address. So, change in data required Synchronization with other references
//No default Init
//Mutating kw NOT required
//Support Inheritance
//Store in memory - Heap
//NOT Thread Safe - Each thread shared same Heap (shared memory, so whatever stored in heap is shared and multiple threads can modify shared data at same time, sync issue)
//ARC(Automatic reference counting) Memory Management - Each reference type (eg. class object instance) contain by default "referenceCount" property to keep count of references. when referenceCount of the object instance becomes 0 then ARC removes or deallocate that object instance from memory
//Strong - increase referenceCount
//Weak (weak properties can have value or can be Nil) - DO NOT increase referenceCount
//UnOwned (unowned properties always HAVE value, CAN NOT BE NIL) - DO NOT increase referenceCount
//In closures we capute self as weak using capturing list [weak self] to avoid memory leak. As closure call can come at random times(Async) and at that time our self may or may not be in memory(Heap). So, we need to check self exsistence in memory before using it inside closure. And we don't want to keep that self in memory until closure callback is come that's why we capture self as weak to avoid memory leak.




//ACTOR------
//Same as CLASS but Actor are thread safe!
//Reference type - Copying reference/Address
//No default Init
//NO Inheritance
//Store in memory - Heap
//Thread Safe - All inside Actor is Synchronous as we use "await" to access anything in actor.
//We can call Actor properties and functions ONLY from Async function or Task{} async block
//Mutation of the Actor properties is ONLY permitted inside Actor. so, we can mutate them ONLY using functions of the Actor class
//Inside Actor we are not marking with "async" as they are bydefault async. So, when we call properties(read/write) or functions from OUTSIDE they act as "async" so we always needs "await" to call them.
//We are using "await" before calling Actor properties and functions that's why even it is in HEAP shared memory but only ONE THREAD can access it at a time dur to "await". so, it is thread safe




//Where to use -------
//Struct - Data Models, Views (eg. SwiftUI views)
//Class - ViewModels (can't be Struct because we want to Observe VM)
//Actor - Shared Managers (eg. NetworkManager), Data Storages (CachesManager)



//Why ViewModel Can't be Struct?
// ViewModel - Can't be Struct becuase we want it to be @observable to observe changes, we don't want VM to create new instances. we want to maintain single instance to track states or published properties
// Our SwiftUI "View" is "Struct" and it is re-created or initialitzing multiple times. So, if we create VM Struct. Then, it will also initialize or re-created NEW VM multiple times. But we want VM to create only ONCE so use "Class" for VM.



//UIKit Views are by-default Class
//SwiftUI Views are by-default Struct




struct StructClassActorView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .onAppear {
            runTest()
        }
    }
}



#Preview {
    StructClassActorView()
}





//MARK: Structs
struct MyStruct1 {
    var title: String
    //TO Avoid modifying struct from OUTSIDE-
    //1. Create "let" properties
    //2. Create "private var" properties to modifying within struct if required
    
    //    //If it is let we can not modify struct properties from outside
    //    let title: String
    
    
    //    //Struct has default init, we don't need to write
    //    //Class Don't have default init
    //    init(title: String) {
    //        self.title = title
    //    }
    
    
    //Both updateTitle1 and updateTitle2 will create new struct objects
    //Both updateTitle1 and updateTitle2 internally doing same work
    func updateTitle1() -> MyStruct1 {
        MyStruct1(title: "Struct New title1") //this will also create new struct
    }
    
    //mutating is required in Struct to get the permission to modify struct property because modifying will create new struct
    //mutating is NOT required in Class (because class object address/reference remain same we just modifying its properties)
    mutating func updateTitle2() {
        title = "Struct New title2" //this will also create new struct because it is value type
    }
}

extension StructClassActorView {
    
    func runTest() {
        structTest()
        print("\n------------------------\n")
        classTest()
        print("\n------------------------\n")
        Task {
            await actorTest()
        }
    }
    
    func structTest(){
        
        let struct1 = MyStruct1(title: "Amber")
        print("MyStruct1 : \(struct1.title)")
        
        print("Pass MyStruct1 to MyStruct2")
        var struct2 = struct1
        print("MyStruct2 : \(struct2.title)")
        
        //struct2.title = "Iram" //If it is let we can not modify struct properties from outside
        
        
        //In struct when we modify property me are creating new completly new Struct because it is value type so it create copy
        struct2.title = "Iram"
        print("MyStruct2 : Title change")
        
        print("In Struct ONLY Modified Object2 title is Updated - value type pass")
        print("In Struct there are 2 copies in memory")
        print("MyStruct1 : \(struct1.title)")
        print("MyStruct2 : \(struct2.title)")
    }
}




//MARK: Classes
class MyClass1 {
    //Make properties "let" or "private var" if you don't want anyone modifying from outside
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle() {
        title = "Class New title"
    }
}

extension StructClassActorView {
    
    func classTest(){
        
        let myClass1 = MyClass1(title: "Amber")
        print("MyClass1 : \(myClass1.title)")
        
        print("Pass MyClass1 to MyClass2")
        let myClass2 = myClass1
        print("MyClass2 : \(myClass2.title)")
        
        myClass2.title = "Iram"
        print("MyClass2 : Title change")
        
        print("In Class both Objects title is Updated - reference type pass")
        print("In Class there is ONLY 1 copies in memory")
        print("MyClass1 : \(myClass1.title)")
        print("MyClass2 : \(myClass2.title)")
    }
    
}




//MARK: Actors
actor MyActorClass1 {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle() {
        title = "Actor New title"
    }
}

extension StructClassActorView {
    
    //We can call Actor properties and functions ONLY from Async function or Task{} async block
    func actorTest() async {
        
        let myActorClass1 = MyActorClass1(title: "Amber")
        
        //Reading Actor properties are also required await
        await print("MyActorClass1 : \(myActorClass1.title)")
        
        print("Pass MyActorClass1 to MyActorClass2")
        let myActorClass2 = myActorClass1
        await print("MyActorClass2 : \(myActorClass2.title)")
        
        
        //Mutation of the Actor properties is ONLY permitted inside Actor (So, we can ONLY call functions to mutate them)
        //await myActorClass2.title = "Iram"
        
        
        //Call Actor functions are also required await
        await myActorClass2.updateTitle()
        print("MyActorClass2 : Title change")
        
        print("In Actor both Objects title is Updated - reference type pass")
        print("In Actor there is ONLY 1 copies in memory")
        await print("MyActorClass1 : \(myActorClass1.title)")
        await print("MyActorClass2 : \(myActorClass2.title)")
    }
}
