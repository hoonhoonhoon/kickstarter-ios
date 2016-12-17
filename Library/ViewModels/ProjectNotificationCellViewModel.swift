import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol ProjectNotificationCellViewModelInputs {
  /// Call with the initial cell notification value.
  func configureWith(notification notification: ProjectNotification)

  /// Call when the notification switch is tapped.
  func notificationTapped(on on: Bool)
}

public protocol ProjectNotificationCellViewModelOutputs {
  /// Emits the project name.
  var name: Signal<String, NoError> { get }

  /// Emits true when the notification is turned on, false otherwise.
  var notificationOn: Signal<Bool, NoError> { get }

  /// Emits when an update error has occurred and a message should be displayed.
  var notifyDelegateOfSaveError: Signal<String, NoError> { get }
}

public protocol ProjectNotificationCellViewModelType {
  var inputs: ProjectNotificationCellViewModelInputs { get }
  var outputs: ProjectNotificationCellViewModelOutputs { get }
}

public final class ProjectNotificationCellViewModel: ProjectNotificationCellViewModelType,
  ProjectNotificationCellViewModelInputs, ProjectNotificationCellViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let notification = self.notificationProperty.signal.ignoreNil()
      .map(cached(notification:))

    self.name = notification.map { $0.project.name }

    let toggledNotification = notification
      .takePairWhen(self.notificationTappedProperty.signal)
      .map { (notification, on) in
        notification
          |> ProjectNotification.lens.email .~ on
          |> ProjectNotification.lens.mobile .~ on
    }

    let updateEvent = toggledNotification
      .switchMap {
        AppEnvironment.current.apiService.updateProjectNotification($0)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.notifyDelegateOfSaveError = updateEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.profile_settings_error()
    }

    let previousNotificationOnError = notification
      .switchMap {
        .merge(
          SignalProducer(value: $0),
          SignalProducer(signal: toggledNotification.skipRepeats())
        )
      }
      .combinePrevious()
      .takeWhen(self.notifyDelegateOfSaveError)
      .map { previous, _ in previous }

    Signal.merge(updateEvent.values(), previousNotificationOnError)
      .observeNext(cache(notification:))

    self.notificationOn = Signal.merge(
      notification,
      toggledNotification,
      previousNotificationOnError
      )
      .map { $0.email && $0.mobile }
      .skipRepeats()

    notification
      .takeWhen(self.notificationTappedProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackChangeProjectNotification($0.project) }
  }
  // swiftlint:enable function_body_length

  private let notificationProperty = MutableProperty<ProjectNotification?>(nil)
  public func configureWith(notification notification: ProjectNotification) {
    self.notificationProperty.value = notification
  }

  private let notificationTappedProperty = MutableProperty(false)
  public func notificationTapped(on on: Bool) {
    self.notificationTappedProperty.value = on
  }

  public let name: Signal<String, NoError>
  public let notificationOn: Signal<Bool, NoError>
  public let notifyDelegateOfSaveError: Signal<String, NoError>

  public var inputs: ProjectNotificationCellViewModelInputs { return self }
  public var outputs: ProjectNotificationCellViewModelOutputs { return self }
}

private func cacheKey(forNotification notification: ProjectNotification) -> String {
  return "project_notification_view_model_notification_\(notification.id)"
}

private func cache(notification notification: ProjectNotification) {
  let key = cacheKey(forNotification: notification)
  AppEnvironment.current.cache[key] = (notification.email && notification.mobile)
}

private func cached(notification notification: ProjectNotification) -> ProjectNotification {
  let key = cacheKey(forNotification: notification)
  let on = AppEnvironment.current.cache[key] as? Bool
  return notification
    |> ProjectNotification.lens.email .~ (on ?? notification.email)
    |> ProjectNotification.lens.mobile .~ (on ?? notification.mobile)
}
