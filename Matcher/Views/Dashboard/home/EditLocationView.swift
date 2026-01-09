import MapKit
import SwiftUI
struct EditLocationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var locationText: String
    var onSave: (_ location: String, _ lat: Double, _ long: Double) -> Void
    @StateObject private var searchManager = LocationSearchManager()
    @State private var searchText = ""
    @State private var showSearchResults = true
    @FocusState private var isSearchFocused: Bool
    init(location: String,onSave: @escaping (_ location: String, _ lat: Double, _ long: Double) -> Void) {
        self._locationText = State(initialValue: location)
        self.onSave = onSave
    }
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.splashTop, .splashBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Edit Location")
                    .font(AppFont.manropeSemiBold(20))
                    .padding(.top, 20)
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search Location", text: $searchText)
                        .focused($isSearchFocused)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isSearchFocused = true
                             }
                         }
                        .onChange(of: searchText) {
                            if !searchText.isEmpty {
                                showSearchResults = true
                                searchManager.updateQuery(searchText)
                            } else {
                                showSearchResults = false
                            }
                         }
                        .onTapGesture {
                        if !searchText.isEmpty {
                            showSearchResults = true
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                if showSearchResults && !searchManager.results.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(searchManager.results, id: \.self) { item in
                                Button {
                                    selectLocation(item)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(AppFont.manropeBold(16))
                                            .foregroundColor(.black)
                                        Text(item.subtitle)
                                            .font(AppFont.manropeMedium(12))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                                Divider()
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
    }
    private func selectLocation(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard
                error == nil,
                let mapItem = response?.mapItems.first
            else {
                return
            }
            let coordinate = mapItem.placemark.coordinate
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            locationText = completion.title
            isSearchFocused = false
            withAnimation(.easeInOut) {
                showSearchResults = false
            }
            onSave(completion.title, latitude, longitude)
            dismiss()
        }
    }
}
