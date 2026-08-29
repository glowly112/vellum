import Foundation
import Observation

/// Last removed page. Library shows Undo. Confirm is a fail.
@Observable
final class PageTrash {
    var last: DeletedPage?

    func remember(_ page: DeletedPage) {
        last = page
    }

    func take() -> DeletedPage? {
        let page = last
        last = nil
        return page
    }
}