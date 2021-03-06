//
//  RadiatorValveGroupViewController.swift
//  HighwayCode
//
//  Created by Andrew Vysotskyi on 20.03.2020.
//  Copyright © 2020 Gagnant. All rights reserved.
//

import UIKit
import DifferenceKit
import NVActivityIndicatorView

final class FinesListViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionLayout: CollectionViewDecoratedFlowLayout!

    private let presenter: IFinesListPresenter
    private let cellProvider: IFinesListCellProvider

    private lazy var itemSizeProvider: FinesListCellSizeProviderCachingDecorator = {
        let provider = FinesListCellSizeProvider(collectionView: collectionView)
        return FinesListCellSizeProviderCachingDecorator(provider: provider)
    }()

    private var elementsViewModels: [AnyFinesListElementViewModel]

    init(presenter: IFinesListPresenter, cellProvider: IFinesListCellProvider) {
        self.presenter = presenter
        self.cellProvider = cellProvider
        self.elementsViewModels = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefresh()
        configureNavigationItem()
        configureCollectionView()
        configureCollectionViewLayout()
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        itemSizeProvider.reset()
    }

    // MARK: -

    @objc private func didTriggerRefresh() {
        presenter.didTapUpdate()
    }

}

extension FinesListViewController: IFinesListView {

    func update(viewModel: FinesListViewModel) {
        let changeset = StagedChangeset(source: elementsViewModels, target: viewModel.elements)
        collectionView.reload(using: changeset) { [weak self] elements in
            self?.elementsViewModels = elements
        }
        navigationItem.title = viewModel.title
        setRefreshing(viewModel.isRefreshing)
    }

    func setLoading(_ isLoading: Bool) {
        isLoading ? startAnimating(type: .circleStrokeSpin) : stopAnimating()
    }

}

extension FinesListViewController {

    private func setRefreshing(_ isRefreshing: Bool) {
        let refreshControl = collectionView.refreshControl
        guard !isRefreshing else {
            return
        }
        refreshControl?.endRefreshing()
    }

    private func configureCollectionView() {
        collectionView.contentInset.top = 16
        collectionView.contentInset.bottom = 16
        cellProvider.prepare(controller: self, view: collectionView)
    }

    private func configureCollectionViewLayout() {
        collectionLayout.register(
            CollectionSeparatorReusableView.self, forDecorationViewOfKind: UICollectionView.elementKindSeparator
        )
        collectionLayout.sectionHeadersPinToVisibleBounds = false
    }

    private func configureNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
    }

    private func configureRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didTriggerRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

}

extension FinesListViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elementsViewModels.count
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellProvider.cell(for: elementsViewModels[indexPath.row], at: indexPath)
    }

}

extension FinesListViewController: CollectionViewDelegateDecoratedFlowLayout {

    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt path: IndexPath) -> CGSize {
        return itemSizeProvider.size(for: elementsViewModels[path.row])
    }

    func collectionView(
        _ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 8
    }

    func collectionView(
        _ collectionView: UICollectionView, layout: UICollectionViewLayout, shouldDecorateSection section: Int
    ) -> Bool {
        return false
    }

}
