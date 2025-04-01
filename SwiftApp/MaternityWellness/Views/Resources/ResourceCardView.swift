import SwiftUI

struct ResourceCardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ResourceViewModel(userId: "placeholder")
    let resource: Resource
    var isCompact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
            // Header with type and read time
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: resource.type.icon)
                        .font(.caption)
                        .foregroundColor(Color(resource.category.color))
                    
                    Text(resource.type.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(resource.category.color))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(resource.category.color).opacity(0.1))
                .cornerRadius(4)
                
                Spacer()
                
                if let readTime = resource.readTime {
                    Text("\(readTime) min read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Title and Description
            VStack(alignment: .leading, spacing: isCompact ? 4 : 8) {
                Text(resource.title)
                    .font(isCompact ? .headline : .title3)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                if !isCompact {
                    Text(resource.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            if !isCompact {
                // Tags
                if !resource.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(resource.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Footer with actions
                HStack {
                    // Source or Author
                    if let source = resource.source {
                        Text(source)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if let author = resource.author {
                        Text(author)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Progress indicator if applicable
                    if let progress = viewModel.resourceProgress[resource.id], progress > 0 {
                        HStack(spacing: 4) {
                            ProgressView(value: progress, total: 1.0)
                                .frame(width: 80)
                            
                            Text("\(Int(progress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Bookmark button
                    Button(action: {
                        viewModel.toggleBookmark(resourceId: resource.id)
                    }) {
                        Image(systemName: viewModel.bookmarkedResources.contains(resource.id) ? "bookmark.fill" : "bookmark")
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                if viewModel.userId != userId {
                    viewModel.userId = userId
                    viewModel.loadResources()
                    viewModel.loadBookmarks()
                }
            }
        }
    }
}

struct ResourceCardView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        authViewModel.currentUser = User(username: "testuser", fullName: "Test User", email: "test@example.com")
        
        let sampleResource = Resource(
            title: "Understanding Postpartum Depression",
            description: "Learn about the symptoms, causes, and treatments for postpartum depression.",
            content: "This is the full content of the resource...",
            type: .article,
            category: .mentalHealth,
            author: "Dr. Sarah Wong",
            source: "Singapore Mental Health Association",
            readTime: 10,
            featured: true,
            tags: ["Depression", "Mental Health", "Postpartum"]
        )
        
        return ResourceCardView(resource: sampleResource)
            .padding()
            .previewLayout(.sizeThatFits)
            .environmentObject(authViewModel)
    }
}