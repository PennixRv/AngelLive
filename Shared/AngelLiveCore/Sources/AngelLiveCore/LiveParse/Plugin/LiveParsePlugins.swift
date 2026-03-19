import Foundation

/// 全局插件系统入口。
///
/// 说明：`LiveParsePluginManager` 自带插件缓存（JSContext 等），但如果每次调用都重新创建 manager，会导致缓存失效。
/// 因此提供一个共享实例给各平台调用。
public enum LiveParsePlugins {
    private static func makeSharedManager() -> LiveParsePluginManager {
        // 使用独立的 URLSession，禁用自动 cookie 管理，
        // 避免 HTTPCookieStorage 干扰插件手动设置的 Cookie header。
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = nil
        config.httpCookieAcceptPolicy = .never
        config.httpShouldSetCookies = false
        let session = URLSession(configuration: config)

        let logHandler: LiveParsePluginManager.LogHandler = { msg in
            print("[LiveParse:JS] \(msg)")
        }

        if let manager = try? LiveParsePluginManager(session: session, logHandler: logHandler) {
            return manager
        }

        let fallbackDirectories = [
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true),
        ]
        .compactMap { $0 }
        .map { $0.appendingPathComponent("LiveParse", isDirectory: true) }

        for baseDirectory in fallbackDirectories {
            if let storage = try? LiveParsePluginStorage(baseDirectory: baseDirectory) {
                print("[LiveParse] Falling back to storage base directory: \(baseDirectory.path)")
                return LiveParsePluginManager(storage: storage, session: session, logHandler: logHandler)
            }
        }

        let emergencyBaseDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("LiveParse-Emergency", isDirectory: true)
        print("[LiveParse] Falling back to unchecked emergency storage: \(emergencyBaseDirectory.path)")
        return LiveParsePluginManager(
            storage: .unchecked(baseDirectory: emergencyBaseDirectory),
            session: session,
            logHandler: logHandler
        )
    }

    public static let shared: LiveParsePluginManager = makeSharedManager()

    public static func updatePlatformSession(platformId: String, cookie: String, uid: String? = nil) {
        LiveParsePlatformSessionVault.update(platformId: platformId, cookie: cookie, uid: uid)
    }

    public static func clearPlatformSession(platformId: String) {
        LiveParsePlatformSessionVault.clear(platformId: platformId)
    }
}
