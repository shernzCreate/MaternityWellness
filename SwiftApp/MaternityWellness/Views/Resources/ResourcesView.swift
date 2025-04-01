import SwiftUI

struct ResourcesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ResourceViewModel(userId: "placeholder")
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showingSearch = false
    @State private var selectedResource: Resource?
    
    private let tabs = ["All", "Bookmarked", "In Progress"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            VStack(spacing: 8) {
                                Text(tabs[index])
                                    .font(.subheadline)
                                    .fontWeight(selectedTab == index ? .semibold : .regular)
                                    .foregroundColor(selectedTab == index ? Color("AccentColor") : .secondary)
                                
                                Rectangle()
                                    .fill(selectedTab == index ? Color("AccentColor") : Color.clear)
                                    .frame(height: 3)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 8)
                
                Divider()
                
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: {
                            viewModel.setCategory(nil)
                        }) {
                            CategoryChip(
                                title: "All",
                                isSelected: viewModel.selectedCategory == nil,
                                color: "gray"
                            )
                        }
                        
                        ForEach(ResourceCategory.allCases, id: \.self) { category in
                            Button(action: {
                                viewModel.setCategory(category)
                            }) {
                                CategoryChip(
                                    title: category.rawValue,
                                    isSelected: viewModel.selectedCategory == category,
                                    color: category.color
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
                // Resources list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        switch selectedTab {
                        case 0:
                            ForEach(getFilteredResources()) { resource in
                                ResourceCardView(resource: resource)
                                    .onTapGesture {
                                        selectedResource = resource
                                    }
                            }
                        case 1:
                            if viewModel.getBookmarkedResources().isEmpty {
                                emptyStateView(
                                    icon: "bookmark",
                                    title: "No Bookmarks",
                                    message: "Save resources for later by tapping the bookmark icon."
                                )
                            } else {
                                ForEach(viewModel.getBookmarkedResources()) { resource in
                                    ResourceCardView(resource: resource)
                                        .onTapGesture {
                                            selectedResource = resource
                                        }
                                }
                            }
                        case 2:
                            if viewModel.getResourcesInProgress().isEmpty {
                                emptyStateView(
                                    icon: "book.closed",
                                    title: "Nothing In Progress",
                                    message: "Your progress will be shown here when you start reading resources."
                                )
                            } else {
                                ForEach(viewModel.getResourcesInProgress()) { resource in
                                    ResourceCardView(resource: resource)
                                        .onTapGesture {
                                            selectedResource = resource
                                        }
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Resources")
            .navigationBarItems(trailing:
                Button(action: {
                    showingSearch = true
                }) {
                    Image(systemName: "magnifyingglass")
                }
            )
            .sheet(isPresented: $showingSearch) {
                searchView
            }
            .sheet(item: $selectedResource) { resource in
                ResourceDetailView(resource: resource)
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    if viewModel.userId != userId {
                        viewModel.userId = userId
                        viewModel.loadResources()
                    }
                }
            }
        }
    }
    
    private func getFilteredResources() -> [Resource] {
        if let category = viewModel.selectedCategory {
            return viewModel.categorizedResources[category] ?? []
        } else {
            return viewModel.allResources
        }
    }
    
    private var searchView: some View {
        NavigationView {
            VStack {
                TextField("Search resources...", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)
                    .onChange(of: searchText) { _ in
                        viewModel.searchQuery = searchText
                        viewModel.searchResources()
                    }
                
                if searchText.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Search for resources")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try searching for topics like 'sleep', 'depression', or 'exercise'")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                } else if viewModel.searchResults.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "magnifyingglass.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try using different keywords or browse all resources")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.searchResults) { resource in
                                ResourceCardView(resource: resource)
                                    .onTapGesture {
                                        selectedResource = resource
                                        showingSearch = false
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarItems(trailing: Button("Done") {
                showingSearch = false
            })
        }
    }
    
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(minHeight: 300)
        .padding()
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let color: String
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(color).opacity(0.2) : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? Color(color) : .secondary)
    }
}

struct ResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        authViewModel.currentUser = User(username: "testuser", fullName: "Test User", email: "test@example.com")
        
        return ResourcesView()
            .environmentObject(authViewModel)
    }
}