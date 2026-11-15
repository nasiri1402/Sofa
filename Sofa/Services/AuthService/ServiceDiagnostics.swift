import Foundation

enum ServiceDiagnostics {
    enum Operation: String {
        case authentication, callable, stream
    }

    static func errorCodes(_ error: Error) -> [[String: Any]] {
        let allowedDomains: Set<String> = [
            "FIRAuthErrorDomain", "FIRAuthInternalErrorDomain", "com.firebase.functions",
            "com.firebase.appCheck", "com.google.app_check_core", NSURLErrorDomain,
        ]
        var result: [[String: Any]] = []
        var current: NSError? = error as NSError
        var visited: Set<ObjectIdentifier> = []
        while let value = current, result.count < 4, visited.insert(ObjectIdentifier(value)).inserted {
            var item: [String: Any] = [
                "domain": allowedDomains.contains(value.domain) ? value.domain : "other",
                "code": value.code,
            ]
            if value.domain == "FIRAuthInternalErrorDomain",
               let reason = knownAuthReason(value) {
                item["reason"] = reason
            }
            result.append(item)
            current = value.userInfo[NSUnderlyingErrorKey] as? NSError
        }
        return result
    }

    private static func knownAuthReason(_ error: NSError) -> String? {
        // Classify only known SDK server codes; never copy a server message or its metadata.
        let allowed: Set<String> = [
            "INVALID_APP_CREDENTIAL", "APP_CHECK_TOKEN_INVALID", "API_KEY_INVALID",
            "API_KEY_IOS_APP_BLOCKED", "OPERATION_NOT_ALLOWED", "PROJECT_NOT_FOUND",
            "CONFIGURATION_NOT_FOUND", "BILLING_NOT_ENABLED", "TOO_MANY_ATTEMPTS_TRY_LATER",
        ]
        var response = error.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any]
        if response == nil, error.code == 3,
           let data = error.userInfo["FIRAuthErrorUserInfoDataKey"] as? Data,
           data.count <= 16_384 {
            // The SDK keeps unexpected HTTP responses here. Inspect in memory only;
            // never retain or emit the response, including unknown messages.
            response = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            if response == nil,
               let text = String(data: data, encoding: .utf8),
               isAttestationFailure(text) {
                return "APP_ATTESTATION_FAILED"
            }
        }
        guard let response else { return nil }
        let body = response["error"] as? [String: Any] ?? response
        if let details = body["details"] as? [[String: Any]],
           let reason = details.compactMap({ $0["reason"] as? String }).first(where: allowed.contains) {
            return reason
        }
        if let message = body["message"] as? String {
            if isAttestationFailure(message) { return "APP_ATTESTATION_FAILED" }
            let code = String(message.split(separator: ":", maxSplits: 1).first ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if allowed.contains(code) { return code }
        }
        return nil
    }

    private static func isAttestationFailure(_ message: String) -> Bool {
        let value = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return value == "App attestation failed." || value == "App attestation failed"
    }

    static func record(_ error: Error, operation: Operation) {
        #if DEBUG
        // Only safe scalar metadata, never descriptions, credentials, UID, response bodies or tokens.
        let payload: [String: Any] = [
            "at": ISO8601DateFormatter().string(from: .now),
            "pid": ProcessInfo.processInfo.processIdentifier,
            "operation": operation.rawValue,
            "errors": errorCodes(error),
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: .sortedKeys) {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("sofa-safe-service-diagnostics.json")
            try? data.write(to: url, options: .atomic)
        }
        #endif
    }
}

struct AuthenticationServiceError: LocalizedError {
    let underlying: Error

    var errorDescription: String? {
        String(localized: "authenticationUnavailableMessage")
    }
}
