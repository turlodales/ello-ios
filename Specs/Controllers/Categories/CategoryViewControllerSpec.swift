////
///  CategoryViewControllerSpec.swift
//

@testable
import Ello
import Quick
import Nimble


class CategoryViewControllerSpec: QuickSpec {
    class MockCategoryScreen: CategoryScreenProtocol {
        let topInsetView = UIView()
        var navBarsVisible: Bool?
        var navigationBarTopConstraint: NSLayoutConstraint!
        let navigationBar = ElloNavigationBar()
        var navigationItem: UINavigationItem?
        var categoryTitles: [String] = []
        var scrollTo: Int?

        func setCategoriesInfo(categoriesInfo: [CategoryCardListView.CategoryInfo], animated: Bool) {
            categoryTitles = categoriesInfo.map { $0.title }
        }
        func animateCategoriesList(navBarVisible navBarVisible: Bool) {}
        func scrollToCategoryIndex(index: Int) {
            scrollTo = index
        }
    }

    override func spec() {
        describe("CategoryViewController") {
            let currentUser: User = stub([:])
            var subject: CategoryViewController!
            var screen: MockCategoryScreen!

            beforeEach {
                let category: Ello.Category = Ello.Category.stub([:])
                subject = CategoryViewController(slug: category.slug)
                screen = MockCategoryScreen()
                subject.currentUser = currentUser
                subject.mockScreen = screen
                showController(subject)
            }

            it("has a search button in the nav bar") {
                let rightButtons = subject.elloNavigationItem.rightBarButtonItems
                expect(rightButtons!.count) == 2
            }

            context("setCategories(_:)") {
                it("accepts meta categories") {
                    subject.setCategories([
                        Category.featured,
                        Category.stub(["name": "Art"])
                        ])
                    expect(screen.categoryTitles) == ["Featured", "Art"]
                }

                it("uses internal categories") {
                    subject.setCategories([
                        Category.stub(["name": "Art"])
                        ])
                    expect(screen.categoryTitles) == ["Featured", "Trending", "Recent", "Art"]
                }
            }
        }
    }
}
