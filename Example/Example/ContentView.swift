/// MIT License
///
/// Copyright (c) 2021 Cookpad Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import ExampleKit
import SwiftUI

struct ContentView: View {
    // AppStorage is backed by UserDefaults so this works too!
    @AppStorage(.contentTitle) var title: String?
    @ObservedObject var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.items.isEmpty {
                    Text("No Items")
                        .foregroundColor(Color(.secondaryLabel))
                        .frame(maxWidth: .infinity)
                } else {
                    List {
                        ForEach(viewModel.items, id: \.self) { item in
                            Text("\(item, formatter: viewModel.dateFormatter)")
                        }
                        .onDelete(perform: { viewModel.items.remove(atOffsets: $0) })
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle(title ?? "Untitled")
            .frame(maxHeight: .infinity)
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.addItem() }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
