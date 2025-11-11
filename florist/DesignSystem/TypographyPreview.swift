//
//  TypographyPreview.swift
//  florist
//
//  Created by Al Amin Dwiesta on 11/11/25.
//

import SwiftUI

struct TypographyPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                Text("Typography")
                    .font(.largeTitleGaegu)
                    .padding(.vertical, 20)

                Divider()

                // Typography Scale
                VStack(alignment: .leading, spacing: 20) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Large Title")
                            .font(.largeTitleGaegu)
                        Text("Bold / 37px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title 1")
                            .font(.title1Gaegu)
                        Text("Bold / 31px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title 2")
                            .font(.title2Gaegu)
                        Text("Bold / 29px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title 3")
                            .font(.title3Gaegu)
                        Text("Bold / 21px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Headline")
                            .font(.headlineGaegu)
                        Text("Bold / 19px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Body")
                            .font(.bodyGaegu)
                        Text("Regular / 17px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Callout")
                            .font(.calloutGaegu)
                        Text("Regular / 17px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subhead")
                            .font(.subheadGaegu)
                        Text("Regular / 15px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Footnote")
                            .font(.footnoteGaegu)
                        Text("Regular / 15px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Caption 1")
                            .font(.caption1Gaegu)
                        Text("Regular / 13px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Caption 2")
                            .font(.caption2Gaegu)
                        Text("Regular / 13px")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Example Content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Example Content")
                        .font(.title1Gaegu)

                    Text("The Language of Flowers")
                        .font(.title3Gaegu)

                    Text("In the Victorian era, flowers were used to convey messages that couldn't be spoken aloud. Each flower had its own meaning, creating a secret language of emotions.")
                        .font(.bodyGaegu)
                        .lineSpacing(4)

                    Text("— A Brief History")
                        .font(.calloutGaegu)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical)
            }
            .padding(32)
        }
        .background(Color(red: 0.96, green: 0.93, blue: 0.88))
    }
}

#Preview {
    TypographyPreview()
}
