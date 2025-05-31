//
//  View+Locale.swift
//  Shecan
//
//  Created by Morteza on 5/31/25.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func forceLocale(_ locale: String? ) -> some View {
        if let locale {
            self.environment(\.locale, Locale(identifier: locale))
        } else {
            self
        }
    }
}
