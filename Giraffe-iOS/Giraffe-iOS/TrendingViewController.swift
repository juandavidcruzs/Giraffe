//
//  ViewController.swift
//  Giraffe-iOS
//
//  Created by Evgen Dubinin on 7/3/16.
//  Copyright © 2016 Yevhen Dubinin. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result
import GiraffeKit

final class TrendingViewController: BaseViewController, ViewType {
    private let searchResultSegueIdentiier = "searchResultVC"
    
    let viewModel: TrendingViewModel?                                       = TrendingViewModel(model: Trending())
    
    let searchBar                                                           = UISearchBar.giraffeSearchBar()
    var searchBarButtonItem: UIBarButtonItem?                               = nil
    var animationPlaybackControl: UIBarButtonItem?                          = nil

    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusImageView: UIImageView!
    
    // MARK: View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Search button
        searchBarButtonItem = navigationItem.rightBarButtonItem
        searchBarButtonItem?.target = self
        searchBarButtonItem?.action = #selector(didPressSearchButton)
        
        // Setup Search button
        // TODO: uncomment when is ready to implement
//        animationPlaybackControl = navigationItem.leftBarButtonItem
//        animationPlaybackControl?.target = self
//        animationPlaybackControl?.action = #selector(didChangeAnimationPlayback)
//        animationPlaybackControl?.enabled = false // disabled for now
        
        setupBindings()
    }

    // MARK: RAC Bindings -
    
    func setupBindings() {
        // Setup view helper bindings.
        self.setupViewBindings()
        
        // Setup custom bindings.
        navigationItem.rac_title <~ viewModel!.headline.producer.observeOn(UIScheduler())
        messageLabel.rac_text <~ viewModel!.message.producer.observeOn(UIScheduler())
        containerView.rac_hidden <~ viewModel!.shouldHideItemsView.producer.observeOn(UIScheduler())
        collectionViewController.rac_itemViewModels <~ viewModel!.itemViewModels.producer.observeOn(UIScheduler())
        searchButton.rac_enabled <~ viewModel!.shouldEnableSearchButton.producer.observeOn(UIScheduler())
        loadingIndicator.rac_animated <~ viewModel!.isLoading.producer.map{ $0 }.observeOn(UIScheduler())
        statusImageView.rac_image <~ viewModel!.statusImage.producer.observeOn(UIScheduler())

        viewModel!.didScrollToBottom <~ collectionViewController.racsignal_didScrollToBottom
        
        // search bar
        viewModel!.searchText <~ self.searchBar.rac_text

        self.searchBar.rac_searchBarSearchButtonClicked { [unowned self] searchBar in
            searchBar.resignFirstResponder()
            self.hideSearchBar()
            self.performSegueWithIdentifier(self.searchResultSegueIdentiier, sender: self)
        }
        
        self.searchBar.rac_searchBarCancelButtonClicked { [unowned self] searchBar in
            self.hideSearchBar()
        }
    }

    @objc func didChangeAnimationPlayback() {
        // TODO: start/stop animation
    }
    
    // MARK: Search Bar Presentation -
    
    @objc func didPressSearchButton() {
        showSearchBar()
    }
    
    private func showSearchBar() {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        navigationItem.setRightBarButtonItem(nil, animated: false)
        navigationItem.setLeftBarButtonItem(nil, animated: false)
        UIView.animateWithDuration(0.5, animations: {
            self.searchBar.alpha = 1
            }, completion: { finished in
                self.searchBar.becomeFirstResponder()
        })
    }
    
    private func hideSearchBar() {
        navigationItem.setRightBarButtonItem(searchBarButtonItem, animated: true)
        navigationItem.setLeftBarButtonItem(animationPlaybackControl, animated: true)
        UIView.animateWithDuration(0.3, animations: {
            self.navigationItem.title = self.viewModel!.headline.value
            self.navigationItem.titleView = nil
            }, completion: { finished in
                
        })
    }
    
    // MARK: Storyboard -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == searchResultSegueIdentiier) {
            guard let searchResultVC = segue.destinationViewController as? SearchResultViewController else {
                return
            }
            searchResultVC.bindWith(viewModel: viewModel!.searchResultViewModel.value!)
        }
        else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
}
