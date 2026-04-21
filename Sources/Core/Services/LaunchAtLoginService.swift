protocol LaunchAtLoginManaging {
    func setEnabled(_ isEnabled: Bool)
}

/// Placeholder for v1. The API integration can be done with ServiceManagement.
final class LaunchAtLoginService: LaunchAtLoginManaging {
    func setEnabled(_ isEnabled: Bool) {
        _ = isEnabled
    }
}
