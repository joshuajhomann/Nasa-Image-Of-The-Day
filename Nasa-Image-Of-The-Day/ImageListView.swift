//
//  ContentView.swift
//  Nasa-Image-Of-The-Day
//
//  Created by Joshua Homann on 7/5/21.
//

import SwiftUI

// MARK: - NASAImage
struct NASAImage: Codable, Identifiable {
    var id: URL { url }
    var date, explanation: String
    var hdurl: URL?
    var title: String
    var url: URL

    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl
        case title, url
    }
}

@MainActor
final class ViewModel: ObservableObject {
    @Published var image: Result<[NASAImage], Error>?
    func getRandomImage() async {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.nasa.gov"
        components.path = "/planetary/apod"
        components.queryItems = [
            .init(name: "api_key", value: "DEMO_KEY"),
            .init(name: "count", value: "3")

        ]
        guard let url = components.url else { return }
        image = await Result {
            let (data, _) = try await URLSession.shared.data(from: url)
            print(String(data: data, encoding: .utf8) ?? "no data")
            return try JSONDecoder().decode([NASAImage].self, from: data)
        }
        print(image)
    }
}

extension Result where Failure == Error {
    init(awaiting function: @escaping () async throws -> Success) async {
        do {
            self = .success(try await function())
        } catch {
            self = .failure(error)
        }
    }
}

struct ImageListView: View {
    @StateObject private var viewModel: ViewModel = .init()
    var body: some View {
        NavigationView {
            switch viewModel.image {
            case let .success(nasaImages):
                List(nasaImages) { nasaImage in
                    NavigationLink(destination: {
                        DetailView(nasaImage: nasaImage)
                    }, label: {
                        VStack(alignment: .leading) {
                            AsyncImage(
                                url: nasaImage.url,
                                content: { image in
                                    image
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                },
                                placeholder: { Color.gray }
                            )
                            Text(nasaImage.title).font(.title).foregroundColor(.primary)
                            Text(nasaImage.explanation).font(.body).foregroundColor(.secondary)
                        }
                    })
                }
                .navigationTitle("Image of the day")
            case let .failure(error):
                Text(error.localizedDescription)
            case .none:
                Text("Loading...")
            }
        }
        .task { await viewModel.getRandomImage() }
        .refreshable { await viewModel.getRandomImage() }
    }
}

struct DetailView: View {
    var nasaImage: NASAImage
    @State private var scale = 1.0
    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            AsyncImage(
                url: nasaImage.hdurl ?? nasaImage.url,
                content: { image in
                    image
                        .resizable()
                        .scaleEffect(scale, anchor: .center)
                        .gesture(MagnificationGesture().onChanged { scale = $0 })
                        .onTapGesture(count: 2) { scale = 1.0 }
                },
                placeholder: { Text("loading...") }
            )
         }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle(nasaImage.date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ImageListView()
    }
}
