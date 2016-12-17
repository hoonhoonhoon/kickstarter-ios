@testable import Library
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers
import Prelude
import ReactiveCocoa
import Result
import XCTest

internal final class HelpWebViewModelTests: TestCase {
  private let vm: HelpWebViewModelType = HelpWebViewModel()

  private let webViewLoadRequest = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.webViewLoadRequest.map { $0.URL?.relativePath ?? "" }
      .observe(self.webViewLoadRequest.observer)
  }

  func testWebRequestURLString() {
    self.vm.inputs.configureWith(helpType: .cookie)

    self.webViewLoadRequest.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies"])

    self.vm.inputs.configureWith(helpType: .faq)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies", "/help/faq/kickstarter+basics"])

    self.vm.inputs.configureWith(helpType: .howItWorks)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies", "/help/faq/kickstarter+basics", "/about"])

    self.vm.inputs.configureWith(helpType: .privacy)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies", "/help/faq/kickstarter+basics", "/about", "/privacy"])

    self.vm.inputs.configureWith(helpType: .terms)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies", "/help/faq/kickstarter+basics", "/about", "/privacy",
      "/terms-of-use"])
  }
}
