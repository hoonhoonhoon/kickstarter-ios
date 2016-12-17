import Library
@testable import ReactiveExtensions_TestHelpers
import ReactiveCocoa
import Result
@testable import KsApi

internal final class MessageCellViewModelTests: TestCase {
  private let vm: MessageCellViewModelType = MessageCellViewModel()

  private let avatarURL = TestObserver<NSURL?, NoError>()
  private let body = TestObserver<String, NoError>()
  private let _name = TestObserver<String, NoError>()
  private let timestamp = TestObserver<String, NoError>()
  private let timestampAccessibilityLabel = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.avatarURL.observe(self.avatarURL.observer)
    self.vm.outputs.name.observe(self._name.observer)
    self.vm.outputs.timestamp.observe(self.timestamp.observer)
    self.vm.outputs.timestampAccessibilityLabel.observe(self.timestampAccessibilityLabel.observer)
    self.vm.outputs.body.observe(self.body.observer)
  }

  func testOutputs() {
    let message = Message.template
    self.vm.inputs.configureWith(message: message)

    self.avatarURL.assertValueCount(1)
    self._name.assertValues([message.sender.name])
    self.timestamp.assertValueCount(1)
    self.timestampAccessibilityLabel.assertValueCount(1)
    self.body.assertValues([message.body])
  }
}
