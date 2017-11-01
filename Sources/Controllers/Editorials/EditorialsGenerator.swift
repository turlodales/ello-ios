////
///  EditorialsGenerator.swift
//

final class EditorialsGenerator: StreamGenerator {

    var currentUser: User?
    let streamKind: StreamKind = .editorials
    weak var destination: StreamDestination?

    private var localToken: String = ""
    private var loadingToken = LoadingToken()

    init(currentUser: User?, destination: StreamDestination?) {
        self.currentUser = currentUser
        self.destination = destination
    }

    func load(reload: Bool = false) {
        localToken = loadingToken.resetInitialPageLoadingToken()
        if !reload {
            setPlaceHolders()
        }
        loadEditorialPromotionals()
        loadEditorials()
    }

    static func loadPostStreamEditorials(_ postStreamEditorials: [Editorial], afterAll: AfterBlock) {
        for editorial in postStreamEditorials {
            guard
                editorial.kind == .postStream,
                let path = editorial.postStreamURL
            else { continue }

            let next = afterAll()
            ElloProvider.shared.request(.custom(url: path, mimics: .discover(type: .trending)))
                .thenFinally { data, responseConfig in
                    guard let posts = data as? [Post] else {
                        next()
                        return
                    }
                    editorial.posts = posts
                }
                .always {
                    next()
                }
        }
    }

}

private extension EditorialsGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .promotionalHeader),
            StreamCellItem(type: .placeholder, placeholderType: .editorials)
        ])
    }

    func loadEditorialPromotionals() {
        PagePromotionalService().loadEditorialPromotionals()
            .thenFinally { [weak self] promotionals in
                guard
                    let `self` = self,
                    let promotionals = promotionals
                else { return }

                if let pagePromotional = promotionals.randomItem() {
                    self.destination?.replacePlaceholder(type: .promotionalHeader, items: [
                        StreamCellItem(jsonable: pagePromotional, type: .pagePromotionalHeader),
                        StreamCellItem(type: .spacer(height: EditorialCell.Size.bgMargins.bottom)),
                    ])
                }
            }
            .ignoreErrors()
    }

    func loadEditorials() {
        var editorialItems: [StreamCellItem] = []
        let (afterAll, done) = afterN { [weak self] in
            guard let `self` = self else { return }

            self.destination?.replacePlaceholder(type: .editorials, items: editorialItems) {
                self.destination?.isPagingEnabled = editorialItems.count > 0
            }
        }

        let receivedEditorials = afterAll()
        StreamService().loadStream(streamKind: streamKind)
            .thenFinally { [weak self] response in
                guard
                    let `self` = self,
                    case let .jsonables(jsonables, responseConfig) = response,
                    let editorials = jsonables as? [Editorial]
                else { return }

                self.destination?.setPagingConfig(responseConfig: responseConfig)
                editorialItems += self.parse(jsonables: editorials)

                let postStreamEditorials = editorials.filter { $0.kind == .postStream }
                EditorialsGenerator.loadPostStreamEditorials(postStreamEditorials, afterAll: afterAll)
            }
            .catch { [weak self] _ in
                guard let `self` = self else { return }
                self.destination?.primaryJSONAbleNotFound()
            }
            .always {
                receivedEditorials()
            }
        done()
    }
}
