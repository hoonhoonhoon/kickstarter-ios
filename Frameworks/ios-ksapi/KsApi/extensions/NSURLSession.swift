import Argo
import Curry
import Foundation
import Prelude
import ReactiveCocoa
import Result

private func parseJSONData(data: NSData) -> AnyObject? {
  return try? NSJSONSerialization.JSONObjectWithData(data, options: [])
}

private let queue = dispatch_queue_create("com.kickstarter.ksapi", nil)

internal extension NSURLSession {

  // Wrap an NSURLSession producer with error envelope logic.
  internal func rac_dataResponse(request: NSURLRequest, uploading file: (url: NSURL, name: String)? = nil)
    -> SignalProducer<NSData, ErrorEnvelope> {

      let producer = file.map { self.rac_dataWithRequest(request, uploading: $0, named: $1) }
        ?? self.rac_dataWithRequest(request)

      return producer
        .startOn(QueueScheduler(queue: queue))
        .flatMapError { _ in SignalProducer(error: .couldNotParseErrorEnvelopeJSON) } // NSError
        .flatMap(.Concat) { data, response -> SignalProducer<NSData, ErrorEnvelope> in
          guard let response = response as? NSHTTPURLResponse else { fatalError() }

          guard
            (200..<300).contains(response.statusCode),
            let headers = response.allHeaderFields as? [String:String],
            contentType = headers["Content-Type"] where contentType.hasPrefix("application/json")
            else {

              print("[KsApi] Failure \(self.sanitized(request))")

              if let json = parseJSONData(data) {
                switch decode(json) as Decoded<ErrorEnvelope> {
                case let .Success(envelope):
                  // Got the error envelope
                  return SignalProducer(error: envelope)
                case let .Failure(error):
                  print("Argo decoding error envelope error: \(error)")
                  return SignalProducer(error: .couldNotDecodeJSON(error))
                }
              } else {
                print("Couldn't parse error envelope JSON.")
                return SignalProducer(error: .couldNotParseErrorEnvelopeJSON)
              }
            }

          print("[KsApi] Success \(self.sanitized(request))")
          return SignalProducer(value: data)
        }
  }

  // Converts an NSURLSessionTask into a signal producer of raw JSON data. If the JSON does not parse
  // successfully, an `ErrorEnvelope.errorJSONCouldNotParse()` error is emitted.
  internal func rac_JSONResponse(request: NSURLRequest, uploading file: (url: NSURL, name: String)? = nil)
    -> SignalProducer<AnyObject, ErrorEnvelope> {

      return self.rac_dataResponse(request, uploading: file)
        .map(parseJSONData)
        .flatMap { json -> SignalProducer<AnyObject, ErrorEnvelope> in
          guard let json = json else {
            return .init(error: .couldNotParseJSON)
          }
          return .init(value: json)
        }
  }

  // swiftlint:disable force_try
  private static let sanitationRules = [
    "oauth_token=[REDACTED]":
      try! NSRegularExpression(pattern: "oauth_token=([a-zA-Z0-9]*)", options: .CaseInsensitive),
    "client_id=[REDACTED]":
      try! NSRegularExpression(pattern: "client_id=([a-zA-Z0-9]*)", options: .CaseInsensitive),
    "access_token=[REDACTED]":
      try! NSRegularExpression(pattern: "access_token=([a-zA-Z0-9]*)", options: .CaseInsensitive),
    "password=[REDACTED]":
      try! NSRegularExpression(pattern: "password=([a-zA-Z0-9]*)", options: .CaseInsensitive)
    ]
  // swiftlint:enable force_try

  // Strips sensitive materials from the request, e.g. oauth token, client id, fb token, password, etc...
  private func sanitized(request: NSURLRequest) -> String {
    guard let urlString = request.URL?.absoluteString else { return "" }

    return NSURLSession.sanitationRules.reduce(urlString) { accum, templateAndRule in
      let (template, rule) = templateAndRule
      let range = NSRange(location: 0, length: accum.characters.count)
      return rule.stringByReplacingMatchesInString(accum,
                                                   options: .WithTransparentBounds,
                                                   range: range,
                                                   withTemplate: template)
    } ?? ""
  }
}

private let defaultSessionError =
  NSError(domain: "com.kickstarter.KsApi.rac_dataWithRequest", code: 1, userInfo: nil)

private let boundary = "k1ck574r73r154c0mp4ny"

extension NSURLSession {
  // Returns a producer that will execute the given upload once for each invocation of start().
  private func rac_dataWithRequest(request: NSURLRequest, uploading file: NSURL, named name: String)
    -> SignalProducer<(NSData, NSURLResponse), NSError> {

      guard
        let mutableRequest = request.mutableCopy() as? NSMutableURLRequest,
        let data = optionalize(file.absoluteString).flatMap(NSData.init(contentsOfFile:)),
        let mime = file.imageMime ?? data.imageMime,
        let filename = file.lastPathComponent,
        let multipartHead = ("--\(boundary)\r\n"
          + "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
          + "Content-Type: \(mime)\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding),
        let multipartTail = "--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        else { fatalError() }

      let body = NSMutableData()
      body.appendData(multipartHead)
      body.appendData(data)
      body.appendData(multipartTail)

      mutableRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
      mutableRequest.HTTPBody = body

      return SignalProducer { observer, disposable in
        let task = self.dataTaskWithRequest(mutableRequest) { data, response, error in
          guard let data = data, let response = response else {
            observer.sendFailed(error ?? defaultSessionError)
            return
          }
          observer.sendNext((data, response))
          observer.sendCompleted()
        }
        disposable += task.cancel
        task.resume()
      }
  }
}
