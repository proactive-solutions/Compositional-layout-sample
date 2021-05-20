import UIKit

final class ViewController: UIViewController {
  
  @IBOutlet private weak var searchResultCollectionView: UICollectionView!

  private static let sectionHeaderElementKind = "section-header-element-kind"

  enum Item: Hashable {
    case searches(String)
    case topBrands(String)
    case suggestedForYou(String)
  }

  private enum Section: Int, CaseIterable {
    case trending
    case recent
    case top
    case suggested

    var title: String {
      switch self {
        case .recent:
          return "RECENT SEARCHES"

        case .trending:
          return "TRENDING SEARCHES"

        case .suggested:
          return "SUGGESTED"

        case .top:
          return "TOP BRANDS"
      }
    }
  }

  private var dataSource: UICollectionViewDiffableDataSource<
    Section,
    Item
  >!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    configureHierarchy()
    configureDataSource()
  }
}

private extension ViewController {
  func configureHierarchy() {
    self.searchResultCollectionView.collectionViewLayout = createLayout()
  }
  
  func createLayout() -> UICollectionViewLayout {
    let layout =  UICollectionViewCompositionalLayout {
      (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

      guard let sectionLayoutKind = Section(rawValue: sectionIndex) else { return nil }

      let group: NSCollectionLayoutGroup

      if sectionLayoutKind == .recent ||  sectionLayoutKind == .trending {
        let groupSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(15.0)
        )

        let itemSize = NSCollectionLayoutSize(
          widthDimension: .estimated(20.0),
          heightDimension: .estimated(15.0)
        )

        let item = NSCollectionLayoutItem(
          layoutSize: itemSize
        )

        group = .horizontal(
          layoutSize: groupSize,
          subitems: [item]
        )
      } else {
        let itemSize: NSCollectionLayoutSize
        if sectionLayoutKind == .suggested {
          itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalWidth(1.0 / 3.0)
          )
        } else {
          itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .estimated(200.0)
          )
        }

        let item = NSCollectionLayoutItem(
          layoutSize: itemSize
        )

        let groupSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(200.0)
        )
        group = .horizontal(
          layoutSize: groupSize,
          subitem: item,
          count: 3
        )
      }

      let headerFooterSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(44)
      )
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerFooterSize,
        elementKind: ViewController.sectionHeaderElementKind,
        alignment: .top
      )

      group.interItemSpacing = NSCollectionLayoutSpacing.fixed(5.0)
      let section = NSCollectionLayoutSection(
        group: group
      )

      section.contentInsets = NSDirectionalEdgeInsets(
        top: 10,
        leading: 10,
        bottom: 10,
        trailing: 10
      )
      section.boundarySupplementaryItems = [
        sectionHeader
      ]

      section.interGroupSpacing = 10
      return section
    }
    return layout
  }

  func loadDataOnCollectionView() {
    // load our data
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    Section.allCases.forEach {
      snapshot.appendSections([$0])
      switch $0 {
        case .trending:
          snapshot.appendItems(
            [
              .searches("boots"),
              .searches("booties"),
              .searches("fleece"),
              .searches("sandals"),
              .searches("slippers"),
              .searches("Nike Air Max")
              ]
          )

        case .recent:
          snapshot.appendItems(
            [
              .searches("animal print"),
              .searches("brown boots"),
              .searches("ugg slippers")
            ]
          )

        case .top:
          snapshot.appendItems(
            [
              .topBrands("1"),
              .topBrands("2"),
              .topBrands("3"),
              .topBrands("4"),
              .topBrands("5"),
              .topBrands("6"),
              .topBrands("7"),
            ]
          )

        case .suggested:
          snapshot.appendItems(
            [
              .suggestedForYou("8"),
              .suggestedForYou("9"),
              .suggestedForYou("10"),
              .suggestedForYou("11"),
            ]
          )
      }
    }


    dataSource.apply(snapshot, animatingDifferences: false)
  }

  func headerSupplementaryView(
    headerRegistration: UICollectionView.SupplementaryRegistration<TitleSupplementaryView>
  ) {
    dataSource.supplementaryViewProvider = { (view, kind, index) in
      return self.searchResultCollectionView.dequeueConfiguredReusableSupplementary(
        using: headerRegistration, for: index)
    }
  }

  func registerCells(
    suggestionCellRegistration : UICollectionView.CellRegistration<SuggestionsCell, ViewController.Item>,
    topBrandCellRegistration : UICollectionView.CellRegistration<UICollectionViewCell, ViewController.Item>,
    trendingCellRegistration : UICollectionView.CellRegistration<UICollectionViewCell, ViewController.Item>) {
    dataSource = UICollectionViewDiffableDataSource
    <Section, Item>(collectionView: searchResultCollectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
      // Return the cell.
      guard let section = Section(rawValue: indexPath.section) else {
        fatalError()
      }

      switch section {
        case .recent, .trending:
          return collectionView
            .dequeueConfiguredReusableCell(
              using: suggestionCellRegistration,
              for: indexPath,
              item: item
            )

        case .top:
          return collectionView
            .dequeueConfiguredReusableCell(
              using: topBrandCellRegistration,
              for: indexPath,
              item: item
            )

        case .suggested:
          return collectionView
            .dequeueConfiguredReusableCell(
              using: trendingCellRegistration,
              for: indexPath,
              item: item
            )
      }
    }
  }

  func configureDataSource() {
    let suggestionCellRegistration = UICollectionView.CellRegistration(
      cellNib: UINib(nibName: "SuggestionsCell", bundle: nil)) { (cell: SuggestionsCell, indexPath, item: Item) in
      print(indexPath.section, indexPath.row, indexPath.item, item)

      switch item {
        case .searches(let searches):
          cell.setSearch(title: searches)
          print("searchTitle = \(searches)")
        default:
          print("searchTitle = Default value")
          break
      }
    }

    let trendingCellRegistration = UICollectionView.CellRegistration(
      cellNib: UINib(nibName: "TrendingSearchesCell", bundle: nil)) { (cell, indexPath, item: Item) in
    }

    let topBrandCellRegistration = UICollectionView.CellRegistration(
      cellNib: UINib(nibName: "TopBrandsCell", bundle: nil)) { (cell, indexPath, item: Item) in
    }

    let headerRegistration = UICollectionView.SupplementaryRegistration
    <TitleSupplementaryView>(elementKind: ViewController.sectionHeaderElementKind) {
      (supplementaryView, string, indexPath) in
      guard let section = Section(rawValue: indexPath.section) else {
        fatalError()
      }
      supplementaryView.label.text = section.title
    }
    registerCells(
      suggestionCellRegistration: suggestionCellRegistration,
      topBrandCellRegistration: topBrandCellRegistration,
      trendingCellRegistration: trendingCellRegistration
    )
    headerSupplementaryView(headerRegistration: headerRegistration)
    loadDataOnCollectionView()
  }
}
