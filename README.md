# SwiftDIContainer( Under Construction...)
## Simple Dependeny Injection for Swift
#### This is a project for study and there are no plans to release it.

### Example
Create a class that implements Injectable

```Swift

class ClassA: Injectable {
    typealias Input = String

    let id: String
    var instanceClassB: ClassB!
    var instanceClassC: ClassC!

    required init(input: Input) {
        self.id = input
    }
}
```
Register to an instance of SwiftDIContainer.
Links instances that implement Injectable.
```Swift

class ViewController: UIViewController {

    var instanceClassA = ClassA(input: "classA::id")

    override func viewDidLoad() {
        super.viewDidLoad()
        let container = SwiftDIContainer()
        container.register(instanceClassA)
        container.register(ClassB.self)
        container.register(ClassC.self, input: (index: 0, id: "id"))

        print(instanceClassA.instanceClassB) // Optional(SwiftDIContainerSample.ClassB)
        print(instanceClassB.instanceClassC) //Optional(SwiftDIContainerSample.ClassC)
    }
}
```
