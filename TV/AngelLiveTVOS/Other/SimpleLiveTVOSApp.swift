//
//  SimpleLiveTVOSApp.swift
//  SimpleLiveTVOS
//
//  Created by pc on 2023/6/26.
//

import SwiftUI
import AngelLiveDependencies
import AngelLiveCore
import TipKit

@main
struct SimpleLiveTVOSApp: App {
    private static let bugsnagPlaceholderAPIKey = "YOUR_BUGSNAG_API_KEY_HERE"

    var appViewModel = AppState()

    init() {
        KingfisherManager.shared.defaultOptions += [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default)
        ]
        Self.startBugsnagIfConfigured()

        // 配置 TipKit
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appViewModel: appViewModel)
                .task {
                    // 启动时同步所有平台的 Cookie 到 JS 插件
                    await PlatformSessionLiveParseBridge.syncFromPersistedSessionsOnLaunch()
                    // tvOS 启动时尝试从 iCloud 同步 Cookie
                    if BilibiliCookieSyncService.shared.iCloudSyncEnabled {
                        _ = await BilibiliCookieSyncService.shared.syncFromICloud()
                        await BilibiliCookieSyncService.shared.syncAllPlatformsFromICloud()
                    }
                }
                .onOpenURL { url in
                    appViewModel.handleDeepLink(url: url)
                }
                .fullScreenCover(isPresented: Binding(
                    get: { appViewModel.showDeepLinkPlayer },
                    set: { appViewModel.showDeepLinkPlayer = $0 }
                )) {
                    DeepLinkPlayerView(appViewModel: appViewModel)
                }
        }
    }

    private static func startBugsnagIfConfigured() {
        guard
            let bugsnag = Bundle.main.object(forInfoDictionaryKey: "bugsnag") as? [String: Any],
            let apiKey = bugsnag["apiKey"] as? String
        else {
            print("[Startup] Bugsnag config missing; skipping startup.")
            return
        }

        let trimmedAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAPIKey.isEmpty, trimmedAPIKey != bugsnagPlaceholderAPIKey else {
            print("[Startup] Bugsnag API key is empty or placeholder; skipping startup.")
            return
        }

        Bugsnag.start()
    }
}
