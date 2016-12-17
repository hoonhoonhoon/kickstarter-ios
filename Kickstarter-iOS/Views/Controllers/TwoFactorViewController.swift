import Foundation
import UIKit
import ReactiveExtensions
import ReactiveCocoa
import Library
import Prelude

internal final class TwoFactorViewController: UIViewController {
  private let viewModel: TwoFactorViewModelType = TwoFactorViewModel()

  @IBOutlet private weak var codeTextField: UITextField!
  @IBOutlet private weak var formBackgroundView: UIView!
  @IBOutlet private weak var formStackView: UIStackView!
  @IBOutlet private weak var resendButton: UIButton!
  @IBOutlet private weak var submitButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> twoFactorControllerStyle
      |> UIViewController.lens.view.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular ? .init(all: Styles.grid(20)) : .init(all: Styles.grid(3))
    }

    self.codeTextField
      |> tfaCodeFieldStyle

    self.formBackgroundView
      |> cardStyle()
      |> UIView.lens.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular ? .init(all: Styles.grid(10)) : .init(all: Styles.grid(3))
    }

    self.formStackView
      |> UIStackView.lens.spacing .~ Styles.grid(5)

    self.resendButton
      |> borderButtonStyle

    self.submitButton
      |> greenButtonStyle

    self.titleLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_body()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.codeTextField.rac.becomeFirstResponder = self.viewModel.outputs.codeTextFieldBecomeFirstResponder
    self.submitButton.rac.enabled = self.viewModel.outputs.isFormValid

    self.viewModel.outputs.logIntoEnvironment
      .observeNext { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeNext { [weak self] message in
        self?.showError(message)
      }
  }

  internal static func configuredWith(email email: String, password: String) -> TwoFactorViewController {
    let vc = instantiate()
    vc.viewModel.inputs.email(email, password: password)
    return vc
  }

  internal static func configuredWith(facebookAccessToken token: String) -> TwoFactorViewController {
    let vc = instantiate()
    vc.viewModel.inputs.facebookToken(token)
    return vc
  }

  private static func instantiate() -> TwoFactorViewController {
    return Storyboard.Login.instantiate(TwoFactorViewController)
  }

  private func showError(message: String) {
    self.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
  }

  @IBAction
  internal func codeEditingChanged(textField: UITextField) {
    self.viewModel.inputs.codeChanged(textField.text)
  }

  @IBAction
  internal func resendButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.resendPressed()
  }

  @IBAction
  internal func submitButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.submitPressed()
  }
}
