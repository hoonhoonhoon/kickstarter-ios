import ReactiveCocoa
import Result

public protocol SimpleViewModelInputs {
  associatedtype Model
  func model(model: Model)
}

public protocol SimpleViewModelOutputs {
  associatedtype Model
  var model: Signal<Model, NoError> { get }
}

/// Represents the simplest form of a view model: one that wraps a model and exposes a single output
/// for access to that model.
public final class SimpleViewModel<Model>: SimpleViewModelInputs, SimpleViewModelOutputs {

  private let modelProperty = MutableProperty<Model?>(nil)
  public func model(model: Model) {
    self.modelProperty.value = model
  }

  public let model: Signal<Model, NoError>

  public init() {
    self.model = self.modelProperty.signal.ignoreNil()
  }
}
