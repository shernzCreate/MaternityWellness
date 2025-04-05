import SwiftUI

struct ResourcesView: View {
    @State private var searchText = ""
    @State private var selectedFilter: ResourceFilter = .all
    
    enum ResourceFilter: String, CaseIterable {
        case all = "All"
        case articles = "Articles"
        case videos = "Videos"
        case community = "Community"
    }
    
    // Sample resources data
    let resources = [
        ResourceItem(id: 1, title: "Understanding PPD", description: "An overview of postpartum depression symptoms and causes.", category: "Education", type: "Articles", source: "KK Hospital"),
        ResourceItem(id: 2, title: "Coping Strategies", description: "Practical techniques to manage PPD symptoms day to day.", category: "Self-help", type: "Articles", source: "NUH"),
        ResourceItem(id: 3, title: "Postpartum Exercises", description: "Safe exercises for recovery after childbirth.", category: "Physical Health", type: "Videos", source: "MOH Singapore"),
        ResourceItem(id: 4, title: "Local Support Groups", description: "Information on Singapore-based support groups for new mothers.", category: "Support", type: "Community", source: "Community Resources"),
        ResourceItem(id: 5, title: "Impact on Family", description: "How PPD affects children and spouses and ways to cope as a family.", category: "Family", type: "Articles", source: "Singapore Parenting Society"),
        ResourceItem(id: 6, title: "Meditation for New Mothers", description: "Guided meditation sessions specifically for the postpartum period.", category: "Self-help", type: "Videos", source: "Mental Health Singapore")
    ]
    
    var filteredResources: [ResourceItem] {
        let filtered = resources.filter { resource in
            if selectedFilter != .all && resource.type != selectedFilter.rawValue {
                return false
            }
            
            if !searchText.isEmpty {
                return resource.title.lowercased().contains(searchText.lowercased()) ||
                       resource.description.lowercased().contains(searchText.lowercased()) ||
                       resource.category.lowercased().contains(searchText.lowercased())
            }
            
            return true
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search resources", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Filter tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(ResourceFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                            }) {
                                Text(filter.rawValue)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(selectedFilter == filter ? Color.blue : Color.clear)
                                    .foregroundColor(selectedFilter == filter ? .white : .blue)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding()
                }
                
                // Resource list
                if filteredResources.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No resources found")
                            .font(.headline)
                        
                        Text("Try adjusting your search or filter")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    List {
                        ForEach(filteredResources) { resource in
                            NavigationLink(destination: ResourceDetailView(resource: resource)) {
                                ResourceRowView(resource: resource)
                            }
                        }
                    }
                    .listStyle(InsetListStyle())
                }
            }
            .navigationTitle("Resources")
        }
    }
}

struct ResourceItem: Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let type: String
    let source: String
    var content: String {
        "This is placeholder content for \(title). In a real application, this would contain the full article or video content."
    }
}

struct ResourceRowView: View {
    let resource: ResourceItem
    
    var typeIcon: String {
        switch resource.type {
        case "Articles":
            return "doc.text"
        case "Videos":
            return "play.rectangle"
        case "Community":
            return "person.3"
        default:
            return "doc"
        }
    }
    
    var typeColor: Color {
        switch resource.type {
        case "Articles":
            return .blue
        case "Videos":
            return .red
        case "Community":
            return .green
        default:
            return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon based on type
            Image(systemName: typeIcon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(typeColor)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(resource.title)
                    .font(.headline)
                
                Text(resource.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Text(resource.source)
                        .font(.caption2)
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Text(resource.category)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

struct ResourceDetailView: View {
    let resource: ResourceItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text(resource.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(resource.source)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Text("•")
                            .foregroundColor(.gray)
                        
                        Text(resource.category)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Resource type label
                HStack {
                    Image(systemName: resource.type == "Articles" ? "doc.text" : resource.type == "Videos" ? "play.rectangle" : "person.3")
                    Text(resource.type)
                }
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(5)
                .padding(.horizontal)
                
                // If this is a video
                if resource.type == "Videos" {
                    // Video player placeholder
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fit)
                        
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            
                            Text("Video content would play here")
                                .foregroundColor(.white)
                                .padding(.top, 10)
                        }
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 15) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(resource.description)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Divider()
                    
                    Text("Content")
                        .font(.headline)
                    
                    Text(resource.content)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Singapore-specific note
                VStack(alignment: .leading, spacing: 10) {
                    Text("Singapore Resources")
                        .font(.headline)
                    
                    Text("This resource is provided with information relevant to Singapore healthcare context. For more specific information, visit the source website or contact your healthcare provider.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesView()
    }
}
