//
//  PortfolioFormViewController.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//

import UIKit
import FSPagerView
import PhotosUI
import Combine

class PortfolioFormViewController: UIViewController {

    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet weak var furTextField: BaseTextField!
    @IBOutlet weak var descriptionTextView: PaddingTextView!
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var pageControl: FSPageControl!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var saveButton: BaseButton!
    private let viewModel = PortfolioFormViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    var completion: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
    }
    
    func setupUI() {
        setNavigationTitle(title: "Portfoilo")
        navigationItem.hidesBackButton = true
        titleLabels.forEach({ $0.font = .regular(size: 18) })
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        pagerView.layer.masksToBounds = true
        pagerView.layer.borderWidth = 1
        pagerView.layer.borderColor = UIColor.black.cgColor
        pagerView.contentMode = .center
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.itemSize = pagerView.bounds.size
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pageControl.contentHorizontalAlignment = .center
        pageControl.setFillColor(.white, for: .selected)
        pageControl.setFillColor(.black, for: .normal)
        pagerView.dataSource = self
        pagerView.delegate = self
        furTextField.delegate = self
        descriptionTextView.delegate = self
        tapGesture.delegate = self
    }
    
    func subscribe() {
        viewModel.$portfolio
            .receive(on: DispatchQueue.main)
            .sink { [weak self] portfolio in
                guard let self = self else { return }
                self.furTextField.text = portfolio.fur
                self.descriptionTextView.text = portfolio.info
                let isValidPhoto = portfolio.photos.first != UIImage.imagePlaceholder.pngData()
                self.saveButton.isEnabled = (portfolio.info.checkValidation() && isValidPhoto)
                self.pageControl.numberOfPages = portfolio.photos.count
                let size = isValidPhoto ? self.pagerView.bounds.size : CGSize(width: 100, height: 100)
                self.pagerView.itemSize = size
                self.pagerView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func choosePhoto() {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.requestCameraAccess()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.requestPhotoLibraryAccess()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view // Your source view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func clickedSave(_ sender: BaseButton) {
        viewModel.save { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                self.completion?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        viewModel.clear()
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

extension PortfolioFormViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return viewModel.portfolio.photos.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        let data = viewModel.portfolio.photos[index]
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.image = UIImage(data: data)
        return cell
    }
        
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        choosePhoto()
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
}

extension PortfolioFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func requestCameraAccess() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.openCamera()
                }
            }
        case .authorized:
            openCamera()
        case .denied, .restricted:
            showSettingsAlert()
        @unknown default:
            break
        }
    }
    
    private func requestPhotoLibraryAccess() {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        switch photoStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                if status == .authorized {
                    self.openPhotoLibrary()
                }
            }
        case .authorized:
            openPhotoLibrary()
        case .denied, .restricted:
            showSettingsAlert()
        case .limited:
            break
        @unknown default:
            break
        }
    }
    
    private func openCamera() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    private func openPhotoLibrary() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(title: "Access Needed", message: "Please allow access in Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        if let imageData = image?.jpegData(compressionQuality: 1.0) {
            let data = imageData as Data
            viewModel.addImage(data: data)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PortfolioFormViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        viewModel.portfolio.info = textView.text
    }
}

extension PortfolioFormViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.portfolio.fur = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

extension PortfolioFormViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(view.hitTest(touch.location(in: view), with: nil)?.isDescendant(of: pagerView) == true)
    }
}
