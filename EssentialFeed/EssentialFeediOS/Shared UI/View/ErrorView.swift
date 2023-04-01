//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 17.03.2023.
//

import UIKit

public final class ErrorView: UIView {
	@IBOutlet private var errorLabel: UIButton!

	public var message: String? {
		get { return isVisible ? errorLabel.title(for: .normal) : nil }
		set { setMessageAnimated(newValue) }
	}

	public override func awakeFromNib() {
		super.awakeFromNib()

		errorLabel.setTitle(nil, for: .normal)
		alpha = 0
	}

	private var isVisible: Bool {
		return alpha > 0
	}

	private func setMessageAnimated(_ message: String?) {
		if let message = message {
			showAnimated(message)
		} else {
			hideMessageAnimated()
		}
	}

	private func showAnimated(_ message: String) {
		errorLabel.setTitle(message, for: .normal)

		UIView.animate(withDuration: 0.25) {
			self.alpha = 1
		}
	}

	@IBAction private func hideMessageAnimated() {
		UIView.animate(withDuration: 0.25) {
			self.alpha = 0
		} completion: { completed in
			if completed { self.errorLabel.setTitle(nil, for: .normal) }
		}
	}
}
