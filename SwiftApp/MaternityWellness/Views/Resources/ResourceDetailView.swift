import SwiftUI

struct ResourceDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ResourceViewModel(userId: "placeholder")
    let resource: Resource
    @State private var readPosition: Double = 0.0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    // Category and type indicators
                    HStack(spacing: 8) {
                        // Category
                        Text(resource.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(resource.category.color).opacity(0.1))
                            .foregroundColor(Color(resource.category.color))
                            .cornerRadius(4)
                        
                        // Type 
                        HStack(spacing: 4) {
                            Image(systemName: resource.type.icon)
                                .font(.caption)
                            
                            Text(resource.type.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.secondary)
                        .cornerRadius(4)
                        
                        Spacer()
                        
                        // Bookmark button
                        Button(action: {
                            viewModel.toggleBookmark(resourceId: resource.id)
                        }) {
                            Image(systemName: viewModel.bookmarkedResources.contains(resource.id) ? "bookmark.fill" : "bookmark")
                                .font(.headline)
                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                    
                    // Title
                    Text(resource.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(3)
                    
                    // Metadata
                    HStack(spacing: 16) {
                        // Source or Author
                        if let source = resource.source {
                            HStack(spacing: 4) {
                                Image(systemName: "building.2")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(source)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else if let author = resource.author {
                            HStack(spacing: 4) {
                                Image(systemName: "person")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(author)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let readTime = resource.readTime {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(readTime) min read")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let publishDate = resource.publishDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(formatDate(publishDate))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Resource content
                VStack(alignment: .leading, spacing: 20) {
                    if resource.type == .video, let videoUrl = resource.videoUrl {
                        // Video player placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.9))
                                .aspectRatio(16/9, contentMode: .fit)
                            
                            Image(systemName: "play.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .opacity(0.8)
                        }
                        .onTapGesture {
                            // In a real implementation, this would play the video
                            // For now, we'll just simulate opening the URL
                            if let url = URL(string: videoUrl) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    // Description
                    Text(resource.description)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Content (formatted)
                    Text(resource.content)
                        .font(.body)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // In a real implementation, the content would be properly formatted
                    // with images, headers, links, etc. This is a simplified version
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .onChange(of: readPosition) { newValue in
                    // Update progress whenever read position changes
                    viewModel.updateResourceProgress(resourceId: resource.id, progress: newValue)
                }
                
                // Tags
                if !resource.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Related Topics")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(resource.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.footnote)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.1))
                                    .foregroundColor(.secondary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Further reading / related resources
                // In a real implementation, these would be dynamically generated
                VStack(alignment: .leading, spacing: 16) {
                    Text("More Like This")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.getRelatedResources(for: resource, limit: 3)) { relatedResource in
                                ResourceCardView(resource: relatedResource, isCompact: true)
                                    .frame(width: 250, height: 130)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
            .padding(.bottom, 20)
            .background(Color.gray.opacity(0.05))
            .onAppear {
                // Simulate scrolling and track progress
                if let userId = authViewModel.currentUser?.id {
                    if viewModel.userId != userId {
                        viewModel.userId = userId
                        viewModel.loadResources()
                        viewModel.loadBookmarks()
                        viewModel.loadProgress()
                    }
                }
                
                // Start with existing progress if available
                if let progress = viewModel.resourceProgress[resource.id] {
                    readPosition = progress
                }
                
                // Create a timer to simulate the user reading the content
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                    // Simulate progress as user spends time on the page
                    if readPosition < 1.0 {
                        readPosition += 0.1
                        if readPosition > 1.0 {
                            readPosition = 1.0
                            timer.invalidate()
                        }
                    } else {
                        timer.invalidate()
                    }
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            }
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Helper FlowLayout to display tags in multiple rows
struct FlowLayout: Layout {
    var spacing: CGFloat = 4
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        
        var height: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for (i, row) in rows.enumerated() {
            let rowWidth = row.map { $0.sizeThatFits(.unspecified).width }.reduce(0, +)
                + CGFloat(row.count - 1) * spacing
            
            maxWidth = max(maxWidth, rowWidth)
            
            if i < rows.count - 1 {
                height += row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
                height += spacing
            } else {
                height += row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            }
        }
        
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            
            for subview in row {
                let width = subview.sizeThatFits(.unspecified).width
                
                subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: width, height: rowHeight)
                )
                
                x += width + spacing
            }
            
            y += rowHeight + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        let width = proposal.width ?? 0
        
        var rows: [[LayoutSubview]] = [[]]
        var currentRow = 0
        var currentWidth: CGFloat = 0
        
        for subview in subviews {
            let subviewWidth = subview.sizeThatFits(.unspecified).width
            
            if currentWidth + subviewWidth > width && !rows[currentRow].isEmpty {
                currentRow += 1
                rows.append([])
                currentWidth = 0
            }
            
            rows[currentRow].append(subview)
            currentWidth += subviewWidth + spacing
        }
        
        return rows
    }
}

struct ResourceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        authViewModel.currentUser = User(username: "testuser", fullName: "Test User", email: "test@example.com")
        
        let sampleResource = Resource(
            title: "Understanding Postpartum Depression",
            description: "Learn about the symptoms, causes, and treatments for postpartum depression.",
            content: "Postpartum depression (PPD) is a complex mix of physical, emotional, and behavioral changes that happen in some women after giving birth. It's a form of depression that is linked to chemical, social, and psychological changes associated with having a baby. This is a longer article that would include detailed information about symptoms, causes, treatments, and personal stories.",
            type: .article,
            category: .mentalHealth,
            author: "Dr. Sarah Wong",
            source: "Singapore Mental Health Association",
            readTime: 10,
            featured: true,
            tags: ["Depression", "Mental Health", "Postpartum"]
        )
        
        return NavigationView {
            ResourceDetailView(resource: sampleResource)
                .environmentObject(authViewModel)
        }
    }
}