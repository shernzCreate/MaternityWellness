import SwiftUI

struct ResourcesView: View {
    @EnvironmentObject private var resourceViewModel: ResourceViewModel
    @State private var selectedCategory: ResourceCategory = .all
    @State private var searchText = ""
    @State private var showingResourceDetail = false
    @State private var selectedResource: Resource?
    
    var filteredResources: [Resource] {
        var resources = resourceViewModel.resources
        
        // Apply category filter
        if selectedCategory != .all {
            resources = resources.filter { $0.category == selectedCategory }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            resources = resources.filter { 
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
        
        return resources
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search resources", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ResourceCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                action: {
                                    selectedCategory = category
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Resource list
                if resourceViewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if filteredResources.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60)
                            .foregroundColor(.gray)
                        
                        Text("No resources found")
                            .font(.headline)
                        
                        Text("Try adjusting your filters or search terms")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(filteredResources) { resource in
                            ResourceListItem(resource: resource) {
                                selectedResource = resource
                                showingResourceDetail = true
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Resources")
            .onAppear {
                if resourceViewModel.resources.isEmpty {
                    resourceViewModel.loadResources()
                }
            }
            .sheet(isPresented: $showingResourceDetail) {
                if let resource = selectedResource {
                    ResourceDetailView(resource: resource, isPresented: $showingResourceDetail)
                }
            }
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color("AccentColor") : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ResourceListItem: View {
    let resource: Resource
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                // Resource type icon
                Image(systemName: resource.type == .article ? "doc.text" : "video")
                    .padding(12)
                    .background(
                        resource.category.color.opacity(0.2)
                    )
                    .foregroundColor(resource.category.color)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(resource.title)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    // Category & read time
                    HStack {
                        Text(resource.category.rawValue)
                            .font(.caption)
                            .foregroundColor(resource.category.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(resource.category.color.opacity(0.1))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Text(resource.type == .article ? "\(resource.readTimeMinutes) min read" : "\(resource.readTimeMinutes) min video")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct ResourceDetailView: View {
    let resource: Resource
    @Binding var isPresented: Bool
    @State private var showVideo = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header with resource type and category
                    HStack {
                        Label(
                            resource.type == .article ? "Article" : "Video",
                            systemImage: resource.type == .article ? "doc.text" : "video"
                        )
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(resource.category.color)
                        .cornerRadius(20)
                        
                        Spacer()
                        
                        Text(resource.category.rawValue)
                            .font(.caption)
                            .foregroundColor(resource.category.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(resource.category.color.opacity(0.1))
                            .cornerRadius(20)
                    }
                    
                    // Title
                    Text(resource.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    // Resource metadata
                    HStack {
                        Label(
                            resource.type == .article ? "\(resource.readTimeMinutes) min read" : "\(resource.readTimeMinutes) min video",
                            systemImage: "clock"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let author = resource.author {
                            Label(author, systemImage: "person")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Resource content
                    if resource.type == .video {
                        Button(action: {
                            showVideo = true
                        }) {
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.8))
                                        .cornerRadius(12)
                                        .aspectRatio(16/9, contentMode: .fit)
                                    
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60)
                                        .foregroundColor(.white)
                                    
                                    Text("Video Preview")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(4)
                                        .position(x: 60, y: 25)
                                }
                                
                                Text("Tap to play video")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .alert(isPresented: $showVideo) {
                            Alert(
                                title: Text("Video Playback"),
                                message: Text("Video playback would be implemented here in the production app."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    
                    // Description
                    Text(resource.description)
                        .padding(.vertical, 8)
                    
                    // Content
                    Text(resource.content)
                        .lineSpacing(6)
                    
                    // Source information
                    if let source = resource.source {
                        Divider()
                            .padding(.vertical, 16)
                        
                        HStack(alignment: .top) {
                            Image(systemName: "link")
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Source")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(source)
                                    .font(.caption)
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                    }
                    
                    // Disclaimer for medical information
                    if resource.category == .medical {
                        Divider()
                            .padding(.vertical, 16)
                        
                        Text("Disclaimer: This information is for educational purposes only and is not a substitute for professional medical advice. Always consult with a healthcare provider for medical advice.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationBarItems(
                trailing: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                }
            )
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}