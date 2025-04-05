import SwiftUI

struct Resource: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var type: ResourceType
    var source: String
    var link: String
    var isFeatured: Bool = false
    
    enum ResourceType: String {
        case article = "Article"
        case video = "Video"
        case support = "Support"
        case exercise = "Exercise"
    }
}

struct ResourcesView: View {
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    
    let filters = ["All", "Articles", "Videos", "Exercises", "Support"]
    
    // Sample Singapore-specific resources
    let resources = [
        Resource(
            title: "Understanding Postpartum Depression",
            description: "Learn about the signs, symptoms, and treatment options for postpartum depression.",
            type: .article,
            source: "KK Women's and Children's Hospital",
            link: "https://www.kkh.com.sg",
            isFeatured: true
        ),
        Resource(
            title: "Postnatal Care in Singapore",
            description: "Information about postnatal care services available in Singapore.",
            type: .article,
            source: "Ministry of Health Singapore",
            link: "https://www.moh.gov.sg"
        ),
        Resource(
            title: "Perinatal Mental Health Services",
            description: "Overview of mental health services for new mothers in Singapore.",
            type: .article,
            source: "National University Hospital",
            link: "https://www.nuh.com.sg"
        ),
        Resource(
            title: "Gentle Yoga for New Mothers",
            description: "A 15-minute yoga routine designed specifically for postpartum recovery.",
            type: .video,
            source: "Singapore Sports Council",
            link: "https://www.activesg.gov.sg"
        ),
        Resource(
            title: "Postnatal Depression Support Group",
            description: "Connect with other mothers experiencing similar challenges.",
            type: .support,
            source: "Singapore Association for Mental Health",
            link: "https://www.samhealth.org.sg"
        ),
        Resource(
            title: "Postnatal Exercise: When to Start",
            description: "Guidelines for safely returning to exercise after childbirth.",
            type: .article,
            source: "KK Women's and Children's Hospital",
            link: "https://www.kkh.com.sg"
        ),
        Resource(
            title: "Breathing Exercises for Anxiety",
            description: "Simple breathing techniques to help manage anxiety and stress.",
            type: .exercise,
            source: "Institute of Mental Health Singapore",
            link: "https://www.imh.com.sg"
        ),
        Resource(
            title: "Nutrition for New Mothers",
            description: "Dietary recommendations for postpartum recovery and breastfeeding.",
            type: .article,
            source: "Health Promotion Board Singapore",
            link: "https://www.hpb.gov.sg"
        ),
        Resource(
            title: "Sleep Strategies for New Parents",
            description: "Tips for managing sleep deprivation and improving sleep quality.",
            type: .article,
            source: "KK Women's and Children's Hospital",
            link: "https://www.kkh.com.sg"
        ),
        Resource(
            title: "Postpartum Recovery: What to Expect",
            description: "Information about physical and emotional changes after childbirth.",
            type: .video,
            source: "National University Hospital",
            link: "https://www.nuh.com.sg",
            isFeatured: true
        )
    ]
    
    var filteredResources: [Resource] {
        var filtered = resources
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.title.lowercased().contains(searchText.lowercased()) || 
                                         $0.description.lowercased().contains(searchText.lowercased()) }
        }
        
        // Apply category filter
        if let filter = selectedFilter, filter != "All" {
            filtered = filtered.filter { 
                switch filter {
                case "Articles": return $0.type == .article
                case "Videos": return $0.type == .video
                case "Exercises": return $0.type == .exercise
                case "Support": return $0.type == .support
                default: return true
                }
            }
        }
        
        return filtered
    }
    
    var featuredResources: [Resource] {
        return resources.filter { $0.isFeatured }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search resources", text: $searchText)
                            .autocapitalization(.none)
                        
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
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(filters, id: \.self) { filter in
                                FilterChip(
                                    title: filter,
                                    isSelected: filter == selectedFilter,
                                    action: {
                                        if selectedFilter == filter {
                                            selectedFilter = nil
                                        } else {
                                            selectedFilter = filter
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if searchText.isEmpty && selectedFilter == nil {
                        // Featured resources section (only show when no search/filter active)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Featured")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(featuredResources) { resource in
                                        featuredResourceCard(resource)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // All resources
                    VStack(alignment: .leading, spacing: 10) {
                        Text(searchText.isEmpty && selectedFilter == nil ? "All Resources" : "Results")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if filteredResources.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                
                                Text("No resources found")
                                    .font(.headline)
                                
                                Text("Try adjusting your search or filters")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredResources) { resource in
                                    resourceCard(resource)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Singapore-specific note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Singapore Resources")
                            .font(.headline)
                        
                        Text("These resources are specifically curated for mothers in Singapore, with information from local healthcare providers and support services.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Resources", displayMode: .inline)
        }
    }
    
    private func featuredResourceCard(_ resource: Resource) -> some View {
        Button(action: {
            // Open resource
            if let url = URL(string: resource.link) {
                UIApplication.shared.open(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.type.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(getColorForType(resource.type))
                        )
                        .foregroundColor(.white)
                    
                    Text(resource.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(resource.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(resource.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding()
            .frame(width: 240, height: 180)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func resourceCard(_ resource: Resource) -> some View {
        Button(action: {
            // Open resource
            if let url = URL(string: resource.link) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Icon for the resource type
                ZStack {
                    Circle()
                        .fill(getColorForType(resource.type).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: getIconForType(resource.type))
                        .font(.system(size: 20))
                        .foregroundColor(getColorForType(resource.type))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(resource.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(resource.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(resource.source)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(resource.type.rawValue)
                            .font(.caption)
                            .foregroundColor(getColorForType(resource.type))
                            .fontWeight(.medium)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getColorForType(_ type: Resource.ResourceType) -> Color {
        switch type {
        case .article:
            return Color.blue
        case .video:
            return Color.purple
        case .support:
            return Color.green
        case .exercise:
            return Color.orange
        }
    }
    
    private func getIconForType(_ type: Resource.ResourceType) -> String {
        switch type {
        case .article:
            return "doc.text"
        case .video:
            return "play.rectangle"
        case .support:
            return "person.2"
        case .exercise:
            return "figure.walk"
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(isSelected ? Color("AccentColor") : Color(.systemGray6))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}