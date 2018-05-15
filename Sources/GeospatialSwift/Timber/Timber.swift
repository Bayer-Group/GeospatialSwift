import Foundation
import TimberSwift

private let timber: TimberProtocol = Timber(source: Source(title: "Geospatial Swift", version: Bundle.sourceVersion, emoji: "🗺️"))

internal let Log = timber.log
