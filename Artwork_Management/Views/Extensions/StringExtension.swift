//
//  StringExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI

extension String {

        func stringToImage(_ handler: @escaping ((UIImage?)->())) {
            if let url = URL(string: self) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data {
                        let image = UIImage(data: data)
                        handler(image)
                    }
                }.resume()
            } else {
                print("Error: URL(string: self)")
            }
        }
    }
