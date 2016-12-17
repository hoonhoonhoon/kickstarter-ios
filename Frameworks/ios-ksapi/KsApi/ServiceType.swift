// swiftlint:disable file_length
import Foundation
import Prelude
import ReactiveCocoa

public enum Mailbox: String {
  case inbox
  case sent
}

/**
 A type that knows how to perform requests for Kickstarter data.
 */
public protocol ServiceType {
  var appId: String { get }
  var serverConfig: ServerConfigType { get }
  var oauthToken: OauthTokenAuthType? { get }
  var language: String { get }
  var buildVersion: String { get }

  init(appId: String,
       serverConfig: ServerConfigType,
       oauthToken: OauthTokenAuthType?,
       language: String,
       buildVersion: String)

  /// Returns a new service with the oauth token replaced.
  func login(oauthToken: OauthTokenAuthType) -> Self

  /// Returns a new service with the oauth token set to `nil`.
  func logout() -> Self

  /// Request to connect user to Facebook with access token.
  func facebookConnect(facebookAccessToken token: String) -> SignalProducer<User, ErrorEnvelope>

  /// Uploads and attaches an image to the draft of a project update.
  func addImage(file fileURL: NSURL, toDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Image, ErrorEnvelope>

  /// Uploads and attaches a video to the draft of a project update.
  func addVideo(file fileURL: NSURL, toDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Video, ErrorEnvelope>

  func changePaymentMethod(project project: Project)
    -> SignalProducer<ChangePaymentMethodEnvelope, ErrorEnvelope>

  /// Performs the first step of checkout by creating a pledge on the server.
  func createPledge(project project: Project,
                    amount: Double,
                    reward: Reward?,
                    shippingLocation: Location?,
                    tappedReward: Bool) -> SignalProducer<CreatePledgeEnvelope, ErrorEnvelope>

  /// Removes an image from a project update draft.
  func delete(image image: UpdateDraft.Image, fromDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Image, ErrorEnvelope>

  /// Removes a video from a project update draft.
  func delete(video video: UpdateDraft.Video, fromDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Video, ErrorEnvelope>

  /// Fetch a page of activities.
  func fetchActivities(count count: Int?) -> SignalProducer<ActivityEnvelope, ErrorEnvelope>

  /// Fetch activities from a pagination URL
  func fetchActivities(paginationUrl paginationUrl: String) -> SignalProducer<ActivityEnvelope, ErrorEnvelope>

  /// Fetches the current user's backing for the project, if it exists.
  func fetchBacking(forProject project: Project, forUser user: User)
    -> SignalProducer<Backing, ErrorEnvelope>

  /// Fetch all categories.
  func fetchCategories() -> SignalProducer<CategoriesEnvelope, ErrorEnvelope>

  /// Fetch the newest data for a particular category.
  func fetchCategory(param param: Param) -> SignalProducer<Category, ErrorEnvelope>

  /// Fetch a checkout's status.
  func fetchCheckout(checkoutUrl url: String) -> SignalProducer<CheckoutEnvelope, ErrorEnvelope>

  /// Fetch comments from a pagination url.
  func fetchComments(paginationUrl url: String) -> SignalProducer<CommentsEnvelope, ErrorEnvelope>

  /// Fetch comments for a project.
  func fetchComments(project project: Project) -> SignalProducer<CommentsEnvelope, ErrorEnvelope>

  /// Fetch comments for an update.
  func fetchComments(update update: Update) -> SignalProducer<CommentsEnvelope, ErrorEnvelope>

  /// Fetch the config.
  func fetchConfig() -> SignalProducer<Config, ErrorEnvelope>

  /// Fetch discovery envelope with a pagination url.
  func fetchDiscovery(paginationUrl paginationUrl: String) -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope>

  /// Fetch the full discovery envelope with specified discovery params.
  func fetchDiscovery(params params: DiscoveryParams) -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope>

  /// Fetch friends for a user.
  func fetchFriends() -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope>

  /// Fetch friends from a pagination url.
  func fetchFriends(paginationUrl paginationUrl: String) -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope>

  /// Fetch friend stats.
  func fetchFriendStats() -> SignalProducer<FriendStatsEnvelope, ErrorEnvelope>

  /// Fetches all of the messages in a particular message thread.
  func fetchMessageThread(messageThreadId messageThreadId: Int)
    -> SignalProducer<MessageThreadEnvelope, ErrorEnvelope>

  /// Fetches all of the messages related to a particular backing.
  func fetchMessageThread(backing backing: Backing) -> SignalProducer<MessageThreadEnvelope, ErrorEnvelope>

  /// Fetches all of the messages in a particular mailbox and specific to a particular project.
  func fetchMessageThreads(mailbox mailbox: Mailbox, project: Project?)
    -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope>

  /// Fetches more messages threads from a pagination URL.
  func fetchMessageThreads(paginationUrl paginationUrl: String)
    -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope>

  /// Fetch the newest data for a particular project from its id.
  func fetchProject(param param: Param) -> SignalProducer<Project, ErrorEnvelope>

  /// Fetch a single project with the specified discovery params.
  func fetchProject(params: DiscoveryParams) -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope>

  /// Fetch the newest data for a particular project from its project value.
  func fetchProject(project project: Project) -> SignalProducer<Project, ErrorEnvelope>

  /// Fetch a page of activities for a project.
  func fetchProjectActivities(forProject project: Project) ->
    SignalProducer<ProjectActivityEnvelope, ErrorEnvelope>

  /// Fetch a page of activities for a project from a pagination url.
  func fetchProjectActivities(paginationUrl paginationUrl: String) ->
    SignalProducer<ProjectActivityEnvelope, ErrorEnvelope>

  /// Fetch the user's project notifications.
  func fetchProjectNotifications() -> SignalProducer<[ProjectNotification], ErrorEnvelope>

  /// Fetches the projects that the current user is a member of.
  func fetchProjects(member member: Bool) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope>

  /// Fetches more projects from a pagination URL.
  func fetchProjects(paginationUrl paginationUrl: String) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope>

  /// Fetches the stats for a particular project.
  func fetchProjectStats(projectId projectId: Int) -> SignalProducer<ProjectStatsEnvelope, ErrorEnvelope>

  /// Fetches a reward for a project and reward id.
  func fetchRewardShippingRules(projectId projectId: Int, rewardId: Int)
    -> SignalProducer<ShippingRulesEnvelope, ErrorEnvelope>

  /// Fetches a survey response belonging to the current user.
  func fetchSurveyResponse(surveyResponseId surveyResponseId: Int)
    -> SignalProducer<SurveyResponse, ErrorEnvelope>

  /// Fetches all of the user's unanswered surveys.
  func fetchUnansweredSurveyResponses() -> SignalProducer<[SurveyResponse], ErrorEnvelope>

  /// Fetches an update from its id and project.
  func fetchUpdate(updateId updateId: Int, projectParam: Param) -> SignalProducer<Update, ErrorEnvelope>

  /// Fetches a project update draft.
  func fetchUpdateDraft(forProject project: Project) -> SignalProducer<UpdateDraft, ErrorEnvelope>

  /// Fetches the current user's backed projects.
  func fetchUserProjectsBacked() -> SignalProducer<ProjectsEnvelope, ErrorEnvelope>

  /// Fetches more user backed projects.
  func fetchUserProjectsBacked(paginationUrl url: String) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope>

  /// Fetch the newest data for a particular user.
  func fetchUser(user: User) -> SignalProducer<User, ErrorEnvelope>

  /// Fetch a user.
  func fetchUser(userId userId: Int) -> SignalProducer<User, ErrorEnvelope>

  /// Fetch the logged-in user's data.
  func fetchUserSelf() -> SignalProducer<User, ErrorEnvelope>

  /// Follow all friends of current user.
  func followAllFriends() -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Follow a user with their id.
  func followFriend(userId id: Int) -> SignalProducer<User, ErrorEnvelope>

  /// Increment the video complete stat for a project.
  func incrementVideoCompletion(forProject project: Project) -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Increment the video start stat for a project.
  func incrementVideoStart(forProject project: Project) -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Attempt a login with an email, password and optional code.
  func login(email email: String, password: String, code: String?) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  /// Attempt a login with Facebook access token and optional code.
  func login(facebookAccessToken facebookAccessToken: String, code: String?) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  /// Marks all the messages in a particular thread as read.
  func markAsRead(messageThread messageThread: MessageThread) -> SignalProducer<MessageThread, ErrorEnvelope>

  /// Posts a comment to a project.
  func postComment(body: String, toProject project: Project) -> SignalProducer<Comment, ErrorEnvelope>

  /// Posts a comment to an update.
  func postComment(body: String, toUpdate update: Update) -> SignalProducer<Comment, ErrorEnvelope>

  /// Returns a project update preview URL.
  func previewUrl(forDraft draft: UpdateDraft) -> NSURL?

  /// Publishes a project update draft.
  func publish(draft draft: UpdateDraft) -> SignalProducer<Update, ErrorEnvelope>

  /// Registers a push token.
  func register(pushToken pushToken: String) -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Reset user password with email address.
  func resetPassword(email email: String) -> SignalProducer<User, ErrorEnvelope>

  /// Searches all of the messages, (optionally) bucketed to a specific project.
  func searchMessages(query query: String, project: Project?)
    -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope>

  /// Sends a message to a subject, i.e. creator project, message thread, backer of backing.
  func sendMessage(body body: String, toSubject subject: MessageSubject)
    -> SignalProducer<Message, ErrorEnvelope>

  /// Signup with email.
  func signup(name name: String, email: String, password: String, passwordConfirmation: String,
                   sendNewsletters: Bool) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  /// Signup with Facebook access token and newsletter bool.
  func signup(facebookAccessToken facebookAccessToken: String, sendNewsletters: Bool) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  /// Star a project.
  func star(project: Project) -> SignalProducer<StarEnvelope, ErrorEnvelope>

  func submitApplePay(checkoutUrl checkoutUrl: String,
                      stripeToken: String,
                      paymentInstrumentName: String,
                      paymentNetwork: String,
                      transactionIdentifier: String) -> SignalProducer<SubmitApplePayEnvelope, ErrorEnvelope>

  /// Toggle the starred state on a project.
  func toggleStar(project: Project) -> SignalProducer<StarEnvelope, ErrorEnvelope>

  /// Unfollow a user with their id.
  func unfollowFriend(userId id: Int) -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Performs the first step of checkout by creating a pledge on the server.
  func updatePledge(project project: Project,
                            amount: Double,
                            reward: Reward?,
                            shippingLocation: Location?,
                            tappedReward: Bool) -> SignalProducer<UpdatePledgeEnvelope, ErrorEnvelope>

  /// Update the project notification setting.
  func updateProjectNotification(notification: ProjectNotification) ->
    SignalProducer<ProjectNotification, ErrorEnvelope>

  /// Update the current user with settings attributes.
  func updateUserSelf(user: User) -> SignalProducer<User, ErrorEnvelope>

  /// Updates the draft of a project update.
  func update(draft draft: UpdateDraft, title: String, body: String, isPublic: Bool)
    -> SignalProducer<UpdateDraft, ErrorEnvelope>
}

extension ServiceType {
  /// Returns `true` if an oauth token is present, and `false` otherwise.
  public var isAuthenticated: Bool {
    return self.oauthToken != nil
  }
}

public func == (lhs: ServiceType, rhs: ServiceType) -> Bool {
  return
    lhs.dynamicType == rhs.dynamicType &&
      lhs.serverConfig == rhs.serverConfig &&
      lhs.oauthToken == rhs.oauthToken &&
      lhs.language == rhs.language &&
      lhs.buildVersion == rhs.buildVersion
}

public func != (lhs: ServiceType, rhs: ServiceType) -> Bool {
  return !(lhs == rhs)
}

extension ServiceType {

  /**
   Prepares a URL request to be sent to the server.

   - parameter originalRequest: The request that should be prepared.
   - parameter query:           Additional query params that should be attached to the request.

   - returns: A new URL request that is properly configured for the server.
   */
  public func preparedRequest(forRequest originalRequest: NSURLRequest, query: [String:AnyObject] = [:])
    -> NSURLRequest {

      guard let request = originalRequest.mutableCopy() as? NSMutableURLRequest else {
        return originalRequest
      }
      guard let URL = request.URL else {
        return originalRequest
      }

      var headers = self.defaultHeaders

      let method = request.HTTPMethod.uppercaseString
      let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false)!
      var queryItems = components.queryItems ?? []
      queryItems.appendContentsOf(self.defaultQueryParams.map(NSURLQueryItem.init(name:value:)))

      if method == "POST" || method == "PUT" {
        if request.HTTPBody == nil {
          headers["Content-Type"] = "application/json; charset=utf-8"
          request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(query, options: [])
        }
      } else {
        queryItems.appendContentsOf(
          query
            .flatMap(queryComponents)
            .map(NSURLQueryItem.init(name:value:))
        )
      }
      components.queryItems = queryItems.sort { $0.name < $1.name }
      request.URL = components.URL

      let currentHeaders = request.allHTTPHeaderFields ?? [:]
      request.allHTTPHeaderFields = currentHeaders.withAllValuesFrom(headers)

      return request
  }

  /**
   Prepares a request to be sent to the server.

   - parameter URL:    The URL to turn into a request and prepare.
   - parameter method: The HTTP verb to use for the request.
   - parameter query:  Additional query params that should be attached to the request.

   - returns: A new URL request that is properly configured for the server.
   */
  public func preparedRequest(forURL URL: NSURL, method: Method = .GET, query: [String:AnyObject] = [:])
    -> NSURLRequest {

      let request = NSMutableURLRequest(URL: URL)
      request.HTTPMethod = method.rawValue
      return self.preparedRequest(forRequest: request, query: query)
  }

  public func isPrepared(request request: NSURLRequest) -> Bool {
    return request.valueForHTTPHeaderField("Authorization") == authorizationHeader
      && request.valueForHTTPHeaderField("Kickstarter-iOS-App") != nil
  }

  private var defaultHeaders: [String:String] {
    var headers: [String:String] = [:]
    headers["Accept-Language"] = self.language
    headers["Authorization"] = self.authorizationHeader
    headers["Kickstarter-App-Id"] = self.appId
    headers["Kickstarter-iOS-App"] = self.buildVersion

    let executable = NSBundle.mainBundle().infoDictionary?["CFBundleExecutable"]
    let bundleIdentifier = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"]
    let app: AnyObject = (executable ?? bundleIdentifier) ?? "Kickstarter"
    let bundleVersion: AnyObject = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] ?? "1"
    let model = UIDevice.currentDevice().model
    let systemVersion = UIDevice.currentDevice().systemVersion
    let scale = UIScreen.mainScreen().scale

    headers["User-Agent"] = "\(app)/\(bundleVersion) (\(model); iOS \(systemVersion) Scale/\(scale))"

    return headers
  }

  private var authorizationHeader: String? {
    if let token = self.oauthToken?.token {
      return "token \(token)"
    } else {
      return self.serverConfig.basicHTTPAuth?.authorizationHeader
    }
  }

  private var defaultQueryParams: [String:String] {
    var query: [String:String] = [:]
    query["client_id"] = self.serverConfig.apiClientAuth.clientId
    query["oauth_token"] = self.oauthToken?.token
    return query
  }

  private func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
    var components: [(String, String)] = []

    if let dictionary = value as? [String: AnyObject] {
      for (nestedKey, value) in dictionary {
        components += queryComponents("\(key)[\(nestedKey)]", value)
      }
    } else if let array = value as? [AnyObject] {
      for value in array {
        components += queryComponents("\(key)[]", value)
      }
    } else {
      components.append((key, String(value)))
    }

    return components
  }
}
// swiftlint:enable file_length
