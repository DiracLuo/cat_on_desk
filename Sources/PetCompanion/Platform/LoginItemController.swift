import Foundation
import ServiceManagement

final class LoginItemController {
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    var statusDescription: String {
        switch SMAppService.mainApp.status {
        case .enabled:
            return "已开启"
        case .requiresApproval:
            return "需要在系统设置中批准"
        case .notRegistered:
            return "未开启"
        case .notFound:
            return "未找到应用包"
        @unknown default:
            return "未知状态"
        }
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
