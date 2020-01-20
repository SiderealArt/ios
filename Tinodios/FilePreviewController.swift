//
//  ImagePreviewController.swift
//  Tinodios
//
//  Copyright © 2019-2020 Tinode. All rights reserved.
//

import UIKit
import TinodeSDK

struct FilePreviewContent {
    let data: Data
    let refUrl: URL?
    let fileName: String?
    let contentType: String?
    let size: Int64?
}

class FilePreviewController : UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentTypeLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    var previewContent: FilePreviewContent? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        guard let content = self.previewContent else { return }

        // Set icon appropriate for mime type
        imageView.image = UIImage(named: FilePreviewController.iconFromMime(previewContent?.contentType))

        // Fill out details panel for the received image.
        fileNameLabel.text = content.fileName ?? "undefined"
        contentTypeLabel.text = content.contentType ?? "undefined"
        var sizeString = "?? KB"
        if let size = content.size {
            sizeString = UiUtils.bytesToHumanSize(size)
        }
        sizeLabel.text = sizeString

        setInterfaceColors()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard UIApplication.shared.applicationState == .active else {
            return
        }
        self.setInterfaceColors()
    }

    private func setInterfaceColors() {
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            self.view.backgroundColor = .black
        } else {
            self.view.backgroundColor = .white
        }
    }

    func sendFileBar() {
        // This notification is received by the MessageViewController.
        NotificationCenter.default.post(name: Notification.Name("SendAttachment"), object: msg)
        // Return to MessageViewController.
        navigationController?.popViewController(animated: true)
    }

    // Get material icon name from mime type.
    // If more icons become available in material icons, add them to this mime-to-icon mapping.
    static let kMimeToIcon: [String:String] = [:]
    static let kDefaultIcon = "document"
    private static func iconFromMime(_ mime: String?) -> String {
        guard let mime = mime else { return FilePreviewController.kDefaultIcon }

        if let icon = FilePreviewController.kMimeToIcon[mime] {
            return icon
        }

        let parts = mime.split(separator: "/")
        if let icon = FilePreviewController.kMimeToIcon[String(parts[0])] {
            return icon
        }

        return FilePreviewController.kDefaultIcon
    }
}
